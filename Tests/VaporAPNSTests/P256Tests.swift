//
//  P256Tests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 29/09/2016.
//
//

import XCTest
@testable import VaporAPNS
import Foundation

class P256Tests: XCTestCase { // TODO: Set this up so others can test this 😉

    var p256: P256! = nil
    
    override func setUp() {
        p256 = P256()
    }
    
    func testThings() throws {
        let privKey = "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgh/cNUT9iHSN3rxCJeVfB2RxwiL9a61r1nduaNUWcHQKgCgYIKoZIzj0DAQehRANCAAThNihl2oAHKb0d9UCbDJLQRhcMqPzaeyXhG7JwTIL4mtFAXnZYXQP5uWOuZaJrsWpUUUT2UW9DdzBWmnwnBOZm"
        let message = try "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiSm9obiBEb2UiLCJhZG1pbiI6ImZhbHNlIiwic3ViIjoiMTIzNDU2Nzg5MCJ9".makeBytes()
        try p256.hash(privateKey: "secret", message: message)
    }
}
