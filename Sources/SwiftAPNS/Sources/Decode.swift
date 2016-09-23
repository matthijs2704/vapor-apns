/// HPACK Decoding Error
enum DecoderError : Error {
  case integerEncoding
  case invalidTableIndex(Int)
  case invalidString
  case unsupported
}


/// HPACK Decoder
open class Decoder {
  var headerTable = HeaderTable()

  /// Size of he HPACK header table
  open var headerTableSize: Int {
    return headerTable.maxSize
  }

  public init() {}

  /// Takes an HPACK-encoded header block and decodes into an array of headers
  open func decode(_ data: [UInt8]) throws -> [Header] {
    var headers: [Header] = []
    var index = data.startIndex

    while index != data.endIndex {
      let byte = data[index]

      if byte & 0b1000_0000 == 0b1000_0000 {
        // Indexed Header Field Representation
        let (header, consumed) = try decodeIndexed(Array(data[data.indices.suffix(from: index)]))
        headers.append(header)
        index = index.advanced(by: consumed)
      } else if byte & 0b1100_0000 == 0b0100_0000 {
        // Literal Header Field with Incremental Indexing
        let (header, consumed) = try decodeLiteral(Array(data[data.indices.suffix(from: index)]), prefix: 6)
        headers.append(header)
        index = index.advanced(by: consumed)

        headerTable.add(name: header.name, value: header.value)
      } else if byte & 0b1111_0000 == 0b0000_0000 {
        // Literal Header Field without Indexing
        let (header, consumed) = try decodeLiteral(Array(data[data.indices.suffix(from: index)]), prefix: 4)
        headers.append(header)
        index = index.advanced(by: consumed)
      } else if byte & 0b1111_0000 == 0b0001_0000 {
        // Literal Header Field never Indexed
        let (name, nameEndIndex) = try decodeString(Array(data[data.indices.suffix(from: index + 1)]))
        let (value, valueEndIndex) = try decodeString(Array(data[data.indices.suffix(from: (index + nameEndIndex + 1))]))
        headers.append((name, value))

        index = index.advanced(by: 1).advanced(by: nameEndIndex).advanced(by: valueEndIndex)
      } else if byte & 0b1110_0000 == 0b0010_0000 {
        // Dynamic Table Size Update
        let (newSize, consumed) = try decodeInt(data, prefixBits: 5)
        index = index.advanced(by: consumed)
        headerTable.maxSize = newSize
      } else {
        throw DecoderError.unsupported
      }
    }

    return headers
  }

  /// Decodes a header represented using the indexed representation
  func decodeIndexed(_ bytes: [UInt8]) throws -> (header: Header, consumed: Int) {
    let index = try decodeInt(bytes, prefixBits: 7)

    if let header = headerTable[index.value] {
      return (header, index.consumed)
    }

    throw DecoderError.invalidTableIndex(index.value)
  }

  func decodeLiteral(_ bytes: [UInt8], prefix: Int) throws -> (value: Header, consumed: Int) {
    let (index, consumed) = try decodeInt(bytes, prefixBits: prefix)
    var byteIndex = bytes.startIndex.advanced(by: consumed)

    let name: String

    if index == 0 {
      let result = try decodeString(Array(bytes[bytes.indices.suffix(from: byteIndex)]))
      name = result.value
      byteIndex = byteIndex.advanced(by: result.consumed)
    } else if let header = headerTable[index] {
      name = header.name
    } else {
      throw DecoderError.invalidTableIndex(index)
    }

    let (value, valueConsumed) = try decodeString(Array(bytes[bytes.indices.suffix(from: byteIndex)]))
    byteIndex = byteIndex.advanced(by: valueConsumed)
    return ((name, value), byteIndex)
  }

  func decodeString(_ bytes: [UInt8]) throws -> (value: String, consumed: Int) {
    if bytes.isEmpty {
      throw DecoderError.unsupported
    }

    let (length, startIndex) = try decodeInt(bytes, prefixBits: 7)
    let endIndex = startIndex.advanced(by: length)

    if endIndex > bytes.count {
      throw DecoderError.invalidString
    }

    let bytes = (bytes[startIndex ..< endIndex] + [0])
    if let byte = bytes.first , (byte & UInt8(0x80)) > 0 {
      throw DecoderError.unsupported  // Huffman encoding is unsupported
    }
    let characters = bytes.map { CChar($0) }
    if let value = String(validatingUTF8: characters) {
      return (value, endIndex)
    }

    throw DecoderError.invalidString
  }
}


/// Decodes an integer according to the encoding rules defined in the HPACK spec
func decodeInt(_ data: [UInt8], prefixBits: Int) throws -> (value: Int, consumed: Int) {
  guard !data.isEmpty else { throw DecoderError.integerEncoding }

  let maxNumber = (2 ** prefixBits) - 1
  let mask = UInt8(0xFF >> (8 - prefixBits))
  var index = 0

  func multiple(_ index: Int) -> Int {
    return 128 ** (index - 1)
  }

  var number = Int(data[index] & mask)

  if number == maxNumber {
    while true {
      index += 1

      if index >= data.count {
        throw DecoderError.integerEncoding
      }

      let nextByte = Int(data[index])
      if nextByte >= 128 {
        number += (nextByte - 128) * multiple(index)
      } else {
        number += nextByte * multiple(index)
        break
      }
    }
  }

  return (number, index + 1)
}
