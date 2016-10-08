//
//  PayloadTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/10/2016.
//
//

import Foundation
import XCTest
@testable import class VaporAPNS.Payload

class PayloadTests: XCTestCase { // TODO: Set this up so others can test this 😉
    
    override func setUp() {
//        print ("Hi")
    }
    
    func testInitializer() throws {
    }
    
    func testSimplePush() throws {
        let expectedJSON = "{\"aps\":{\"alert\":{\"body\":\"Test\"}}}"
        
        let payload = Payload.init(message: "Test")
        let plJosn = try payload.makeJSON()
        let plString = try plJosn.toString()
        
        XCTAssertEqual(plString, expectedJSON)
    }

    func testTitleBodyPush() throws {
        let expectedJSON = "{\"aps\":{\"alert\":{\"body\":\"Test body\",\"title\":\"Test title\"}}}"
        
        let payload = Payload.init(title: "Test title", body: "Test body")
        let plJosn = try payload.makeJSON()
        let plString = try plJosn.toString()
        
        XCTAssertEqual(plString, expectedJSON)
    }
    
    func testTitleBodyBadgePush() throws {
        let expectedJSON = "{\"aps\":{\"alert\":{\"body\":\"Test body\",\"title\":\"Test title\"},\"badge\":10}}"
        
        let payload = Payload.init(title: "Test title", body: "Test body", badge: 10)
        let plJosn = try payload.makeJSON()
        let plString = try plJosn.toString()
        
        XCTAssertEqual(plString, expectedJSON)
    }
    
    func testContentAvailablePush() throws {
        let expectedJSON = "{\"aps\":{\"content-available\":true}}"
        
        let payload = Payload.contentAvailable
        let plJosn = try payload.makeJSON()
        let plString = try plJosn.toString()
        
        XCTAssertEqual(plString, expectedJSON)
    }
    
    func testContentAvailableWithExtrasPush() throws {
        let expectedJSON = "{\"IntKey\":101,\"StringKey\":\"StringExtra1\",\"aps\":{\"content-available\":true}}"
        
        let payload = Payload.contentAvailable
        payload.extra["StringKey"] = "StringExtra1"
        payload.extra["IntKey"] = 101
        let plJosn = try payload.makeJSON()
        let plString = try plJosn.toString()
        
        XCTAssertEqual(plString, expectedJSON)
    }
    
    static var allTests : [(String, (VaporAPNSTests) -> () throws -> Void)] {
        return [
            ("testSimplePush", PayloadTestss),
            ("testTitleBodyPush", testTitleBodyPush),
            ("testTitleBodyBadgePush", testTitleBodyBadgePush),
            ("testContentAvailablePush", testContentAvailablePush),
            ("testContentAvailableWithExtrasPush", testContentAvailableWithExtrasPush),
        ]
    }
}
