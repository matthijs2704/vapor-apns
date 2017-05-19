//
//  PayloadTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/10/2016.
//
//

import Foundation
import XCTest
import JSON
@testable import class VaporAPNS.Payload

class PayloadTests: XCTestCase {
    
    func testInitializer() throws {
    }
    
    func testSimplePush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["alert": .object(["body": .string("Test")])])]), in: nil)
        
        let payload = Payload(message: "Test")
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)
        
        XCTAssertNotNil(plNode["aps"]?["alert"]?["body"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["body"]?.string, expectedJSON["aps"]?["alert"]?["body"]?.string)
    }

    func testTitleBodyPush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["alert": .object(["body": .string("Test body"), "title": .string("Test title")])])]), in: nil)
        
        let payload = Payload.init(title: "Test title", body: "Test body")
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)
        
        XCTAssertNotNil(plNode["aps"]?["alert"]?["body"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["body"]?.string, expectedJSON["aps"]?["alert"]?["body"]?.string)
        XCTAssertNotNil(plNode["aps"]?["alert"]?["title"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["title"]?.string, expectedJSON["aps"]?["alert"]?["title"]?.string)
    }
    
    func testTitleBodyBadgePush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["alert": .object(["body": .string("Test body"), "title": .string("Test title")]), "badge": .number(.int(10))])]), in: nil)
        
        let payload = Payload.init(title: "Test title", body: "Test body", badge: 10)
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)
        
        XCTAssertNotNil(plNode["aps"]?["alert"]?["body"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["body"]?.string, expectedJSON["aps"]?["alert"]?["body"]?.string)
        XCTAssertNotNil(plNode["aps"]?["alert"]?["title"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["title"]?.string, expectedJSON["aps"]?["alert"]?["title"]?.string)
        XCTAssertNotNil(plNode["aps"]?["badge"]?.int)
        XCTAssertEqual(plNode["aps"]?["badge"]?.int, expectedJSON["aps"]?["badge"]?.int)
    }

    func testTitleSubtitleBodyPush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["alert": .object(["body": .string("Test body"), "title": .string("Test title"), "subtitle": .string("Test subtitle")])])]), in: nil)

        let payload = Payload.init(title: "Test title", body: "Test body")
        payload.subtitle = "Test subtitle"
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)

        XCTAssertNotNil(plNode["aps"]?["alert"]?["body"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["body"]?.string, expectedJSON["aps"]?["alert"]?["body"]?.string)
        XCTAssertNotNil(plNode["aps"]?["alert"]?["title"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["title"]?.string, expectedJSON["aps"]?["alert"]?["title"]?.string)
        XCTAssertNotNil(plNode["aps"]?["alert"]?["subtitle"]?.string)
        XCTAssertEqual(plNode["aps"]?["alert"]?["subtitle"]?.string, expectedJSON["aps"]?["alert"]?["subtitle"]?.string)
    }

    func testContentAvailablePush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["content-available": .bool(true)])]), in: nil)
        
        let payload = Payload.contentAvailable
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)
        
        XCTAssertNotNil(plNode["aps"]?["content-available"]?.bool)
        XCTAssertEqual(plNode["aps"]?["content-available"]?.bool, expectedJSON["aps"]?["content-available"]?.bool)
    }
    
    func testContentAvailableWithExtrasPush() throws {
        let expectedJSON = Node(node: .object(["aps": .object(["content-available": .bool(true)]), "IntKey": .number(.int(101)), "StringKey": .string("StringExtra1")]), in: nil)
        
        let payload = Payload.contentAvailable
        payload.extra["StringKey"] = "StringExtra1"
        payload.extra["IntKey"] = 101
        let plJSON = try payload.makeJSON()
        let plNode = plJSON.makeNode(in: nil)
        
        XCTAssertNotNil(plNode["aps"]?["content-available"]?.bool)
        XCTAssertEqual(plNode["aps"]?["content-available"]?.bool, expectedJSON["aps"]?["content-available"]?.bool)
        XCTAssertNotNil(plNode["StringKey"]?.string)
        XCTAssertEqual(plNode["StringKey"]?.string, expectedJSON["StringKey"]?.string)
        XCTAssertNotNil(plNode["IntKey"]?.int)
        XCTAssertEqual(plNode["IntKey"]?.int, expectedJSON["IntKey"]?.int)
    }
    
    static var allTests : [(String, (PayloadTests) -> () throws -> Void)] {
        return [
            ("testSimplePush", testSimplePush),
            ("testTitleBodyPush", testTitleBodyPush),
            ("testTitleBodyBadgePush", testTitleBodyBadgePush),
            ("testContentAvailablePush", testContentAvailablePush),
            ("testContentAvailableWithExtrasPush", testContentAvailableWithExtrasPush),
        ]
    }
}
