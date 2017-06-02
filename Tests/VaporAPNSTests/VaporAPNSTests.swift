//
//  VaporAPNSTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import XCTest
@testable import VaporAPNS
import JWT
import Foundation

class VaporAPNSTests: XCTestCase {
    
    let vaporAPNS: VaporAPNS! = nil
    
    func testLoadPrivateKey() throws {
        let folderPath = #file.components(separatedBy: "/").dropLast().joined(separator: "/")
        let filePath = "\(folderPath)/TestAPNSAuthKey.p8"
        
        if FileManager.default.fileExists(atPath: filePath) {
            let (privKey, pubKey) = try filePath.tokenString()
            XCTAssertEqual(privKey, "ALEILVyGWnbBaSaIFDsh0yoZaK+Ej0po/55jG2FR6u6C")
            XCTAssertEqual(pubKey, "BKqKwB6hpXp9SzWGt3YxnHgCEkcbS+JSrhoqkeqru/Nf62MeE958RIiKYsLFA/czdE7ThCt46azneU0IBnMCuQU=")
        } else {
            XCTFail("APNS Authentication key not found!")
        }
    }
    
    func testEncoding() throws {
        let claims: [Claim] = [IssuerClaim(string: "D86BEC0E8B"), IssuedAtClaim()]
        let claimsNode = Node(claims)
        let jwt = try! JWT(
            additionalHeaders: [KeyID("E811E6AE22")],
            payload: claimsNode.converted(to: JSON.self),
            signer: ES256(key: "ALEILVyGWnbBaSaIFDsh0yoZaK+Ej0po/55jG2FR6u6C".bytes.base64Decoded))

        let tokenString = try! jwt.createToken()

        do {
            let jwt2 = try JWT(token: tokenString)
            try jwt2.verifySignature(using: ES256(key: "BKqKwB6hpXp9SzWGt3YxnHgCEkcbS+JSrhoqkeqru/Nf62MeE958RIiKYsLFA/czdE7ThCt46azneU0IBnMCuQU=".bytes.base64Decoded))
        } catch {
            XCTFail("Couldn't verify token, failed with error: \(error)")
        }
    }
    
    static var allTests : [(String, (VaporAPNSTests) -> () throws -> Void)] {
        return [
            ("testLoadPrivateKey", testLoadPrivateKey),
            ("testEncoding", testEncoding),
        ]
    }
}
