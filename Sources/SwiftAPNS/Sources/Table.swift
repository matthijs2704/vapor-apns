/// Implements the combined static and dynamic header table
/// See RFC7541 Section 2.3
struct HeaderTable {
  /// Maximum size of dynamic table.
  /// Default 4096 defined by RFC7541 Section 6.5.2
  var maxSize = 4096 {
    didSet {
      if maxSize == 0 {
        dynamicEntries = []
      } else if dynamicEntries.count > maxSize {
        dynamicEntries = Array(dynamicEntries[0 ..< maxSize])
      }
    }
  }

  /// Constant list of static headers. See RFC7541 Section 2.3.1 A
  let staticEntries: [Header] = [
    (":authority", ""),
    (":method", "GET"),
    (":method", "POST"),
    (":path", "/"),
    (":path", "/index.html"),
    (":scheme", "http"),
    (":scheme", "https"),
    (":status", "200"),
    (":status", "204"),
    (":status", "206"),
    (":status", "304"),
    (":status", "400"),
    (":status", "404"),
    (":status", "500"),
    ("accept-charset", ""),
    ("accept-encoding", "gzip, deflate"),
    ("accept-language", ""),
    ("accept-ranges", ""),
    ("accept", ""),
    ("access-control-allow-origin", ""),
    ("age", ""),
    ("allow", ""),
    ("authorization", ""),
    ("cache-control", ""),
    ("content-disposition", ""),
    ("content-encoding", ""),
    ("content-language", ""),
    ("content-length", ""),
    ("content-location", ""),
    ("content-range", ""),
    ("content-type", ""),
    ("cookie", ""),
    ("date", ""),
    ("etag", ""),
    ("expect", ""),
    ("expires", ""),
    ("from", ""),
    ("host", ""),
    ("if-match", ""),
    ("if-modified-since", ""),
    ("if-none-match", ""),
    ("if-range", ""),
    ("if-unmodified-since", ""),
    ("last-modified", ""),
    ("link", ""),
    ("location", ""),
    ("max-forwards", ""),
    ("proxy-authenticate", ""),
    ("proxy-authorization", ""),
    ("range", ""),
    ("referer", ""),
    ("refresh", ""),
    ("retry-after", ""),
    ("server", ""),
    ("set-cookie", ""),
    ("strict-transport-security", ""),
    ("transfer-encoding", ""),
    ("user-agent", ""),
    ("vary", ""),
    ("via", ""),
    ("www-authenticate", ""),
  ]

  var dynamicEntries: [Header] = []

  init() {}

  subscript(index: Int) -> Header? {
    /// Returns the entry specified by index
    get {
      guard index > 0 else { return nil }

      if index <= staticEntries.count {
        return staticEntries[index - 1]
      }

      if index - staticEntries.count <= dynamicEntries.count {
        return dynamicEntries[index - staticEntries.count - 1]
      }

      return nil
    }
  }

  /// Searches the table for the entry specified by name and value
  func search(name: String, value: String) -> Int? {
    let entry = staticEntries.enumerated().filter { index, header in
      header.name == name && header.value == value
    }.first

    if let entry = entry {
      return entry.0 + 1
    }

    let dynamicEntry = dynamicEntries.enumerated().filter { index, header in
      header.name == name && header.value == value
    }.first

    if let entry = dynamicEntry {
      return staticEntries.count + entry.0 + 1
    }

    return nil
  }

  /// Searches the table for an entry that matches by name
  func search(name: String) -> Int? {
    let entry = staticEntries.enumerated().filter { index, header in
      header.name == name
    }.first

    if let entry = entry {
      return entry.0 + 1
    }

    let dynamicEntry = dynamicEntries.enumerated().filter { index, header in
      header.name == name
    }.first

    if let entry = dynamicEntry {
      return staticEntries.count + entry.0 + 1
    }

    return nil
  }

  /// Adds a new entry to the table
  mutating func add(name: String, value: String) {
    dynamicEntries.append((name, value))
  }
}
