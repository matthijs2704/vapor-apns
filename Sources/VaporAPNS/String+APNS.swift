//
//  String+APNS.swift
//  VaporAPNS
//
//  Created by Nathan Flurry on 9/26/16.
//
//

import Foundation
import CLibreSSL
import Core

extension String {
    private func newECKey() throws -> OpaquePointer {
        guard let ecKey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1) else {
            fatalError()
        }
        return ecKey
    }
    
    /// Converts the string (which is a path for the auth key) to a token string
    func tokenString() throws -> (privateKey: String, publicKey: String) {
        guard FileManager.default.fileExists(atPath: self) else {
            throw TokenError.invalidAuthKey
        }
        
        // Fold p8 file and write it back to the file
        let fileString = try String.init(contentsOfFile: self, encoding: .utf8)
        guard
            let privateKeyString =
            fileString.collapseWhitespace().trimmingCharacters(in: .whitespaces).between(
                "-----BEGIN PRIVATE KEY-----",
                "-----END PRIVATE KEY-----"
                )?.trimmingCharacters(in: .whitespaces)
            else {
                throw TokenError.invalidTokenString
        }
        let splittedText = privateKeyString.splitByLength(64)
        let newText = "-----BEGIN PRIVATE KEY-----\n\(splittedText.joined(separator: "\n"))\n-----END PRIVATE KEY-----"
        try newText.write(toFile: self, atomically: false, encoding: .utf8)
        
        
        var pKey = EVP_PKEY_new()
        
        let fp = fopen(self, "r")
        
        PEM_read_PrivateKey(fp, &pKey, nil, nil)
        
        fclose(fp)
        
        let ecKey = EVP_PKEY_get1_EC_KEY(pKey)
        
        EC_KEY_set_conv_form(ecKey, POINT_CONVERSION_UNCOMPRESSED)

        var pub: UnsafeMutablePointer<UInt8>? = nil
        let pub_len = i2o_ECPublicKey(ecKey, &pub)
        var publicKey = ""
        if let pub = pub {
            var publicBytes = Bytes(repeating: 0, count: Int(pub_len))
            for i in 0..<Int(pub_len) {
                publicBytes[i] = Byte(pub[i])
            }
            let publicData = Data(bytes: publicBytes)
//            print("public key: \(publicData.hexString)")
            publicKey = publicData.hexString
        } else {
            publicKey = ""
        }
        
        let bn = EC_KEY_get0_private_key(ecKey!)
        let privKeyBigNum = BN_bn2hex(bn)
        
        let privateKey = "00\(String.init(validatingUTF8: privKeyBigNum!)!)"
        
//        print (privateKey)
        let privData = privateKey.dataFromHexadecimalString()!
        
        let privBase64String = String(bytes: privData.base64Encoded)
        
        
        let pubData = publicKey.dataFromHexadecimalString()!
        let pubBase64String = String(bytes: pubData.base64Encoded)
        
        return (privBase64String, pubBase64String)
    }
    
    
    /// Create `NSData` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `NSData` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    func dataFromHexadecimalString() -> Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let range = self.range(from: match!.range)
            let byteString = self.substring(with: range!)
            var num = UInt8(byteString, radix: 16)
            data.append(&num!, count: 1)
        }
        
        return data
    }
    
    func splitByLength(_ length: Int) -> [String] {
        var result = [String]()
        var collectedCharacters = [Character]()
        collectedCharacters.reserveCapacity(length)
        var count = 0
        
        for character in self.characters {
            collectedCharacters.append(character)
            count += 1
            if (count == length) {
                // Reached the desired length
                count = 0
                result.append(String(collectedCharacters))
                collectedCharacters.removeAll(keepingCapacity: true)
            }
        }
        
        // Append the remainder
        if !collectedCharacters.isEmpty {
            result.append(String(collectedCharacters))
        }
        
        return result
    }
}

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}

extension Data {
    func hexString() -> String {
        var hexString = ""
        for byte in self {
            hexString += String(format: "%02X", byte)
        }
        
        return hexString
    }
}
