//
//  ApplePushMessageTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 09/10/2016.
//
//

import Foundation
import XCTest
@testable import VaporAPNS

class ApplePushMessageTests: XCTestCase {
    
    func testInitializer() {
        let simplePayload = Payload(message: "Test message")
        let pushMessage = ApplePushMessage(topic: "com.apple.Test", priority: .immediately, expirationDate: nil, payload: simplePayload,sandbox: true, collapseIdentifier: "collapseID", threadIdentifier: "threadId")
        
        XCTAssertEqual(pushMessage.topic, "com.apple.Test")
        XCTAssertTrue(pushMessage.sandbox)
        XCTAssertEqual(pushMessage.collapseIdentifier, "collapseID")
        XCTAssertEqual(pushMessage.threadIdentifier, "threadId")
        XCTAssertEqual(pushMessage.priority, .immediately)
        XCTAssertNil(pushMessage.expirationDate)
        XCTAssertEqual(try! pushMessage.payload.makeJSON(), try! simplePayload.makeJSON())
    }
}
