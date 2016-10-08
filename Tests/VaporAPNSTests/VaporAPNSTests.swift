//
//  VaporAPNSTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import XCTest
@testable import VaporAPNS
import VaporJWT
import JSON

import Foundation
import CLibreSSL
import Core

class VaporAPNSTests: XCTestCase { // TODO: Set this up so others can test this 😉
    
    let vaporAPNS: VaporAPNS! = nil
    
    override func setUp() {
//        print ("Hi")
    }
    
    func testLoadPrivateKey() throws {
        if let filepath = Bundle.init(for: type(of: self)).path(forResource: "TestAPNSAuthKey", ofType: "p8") {
        
            let (privKey, pubKey) = try filepath.tokenString()
            XCTAssertEqual(privKey, "ALEILVyGWnbBaSaIFDsh0yoZaK+Ej0po/55jG2FR6u6C")
            XCTAssertEqual(pubKey, "BKqKwB6hpXp9SzWGt3YxnHgCEkcbS+JSrhoqkeqru/Nf62MeE958RIiKYsLFA/czdE7ThCt46azneU0IBnMCuQU=")
        } else {
            XCTFail("APNS Authentication key not found!")
        }
    }
    
    func testEncoding() throws {
        let currentTime = Date().timeIntervalSince1970
        let jsonPayload = try JSON(node: [
            "iss": "D86BEC0E8B",
            "iat": currentTime
            ])
        
        let jwt = try! JWT(payload: jsonPayload,
                           header: try! JSON(node: ["alg":"ES256","kid":"E811E6AE22","typ":"JWT"]),
                           algorithm: .es(._256("ALEILVyGWnbBaSaIFDsh0yoZaK+Ej0po/55jG2FR6u6C")),
                           encoding: .base64URL)
        
        let tokenString = try! jwt.token()
        
        do {
            let jwt2 = try JWT(token: tokenString, encoding: .base64URL)
            let verified = try jwt2.verifySignature(key: "BKqKwB6hpXp9SzWGt3YxnHgCEkcbS+JSrhoqkeqru/Nf62MeE958RIiKYsLFA/czdE7ThCt46azneU0IBnMCuQU=")
            XCTAssertTrue(verified)
        } catch {
            //                fatalError("\(error)")
            XCTFail ("Couldn't verify token")
        }

    }
}
