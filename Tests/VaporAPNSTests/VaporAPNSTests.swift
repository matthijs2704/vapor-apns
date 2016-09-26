//
//  VaporAPNSTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import XCTest
@testable import VaporAPNS

class VaporAPNSTests: XCTestCase { // TODO: Set this up so others can test this 😉
    
    let vaporAPNS: VaporAPNS! = nil
    
    override func setUp() {
        print ("Hi")
    }
    
    func testInitializer() throws {
        let wrongVaporAPNSInstance = try VaporAPNS(authKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_T36248L7C8.p9")
        XCTAssertNil(wrongVaporAPNSInstance)
        
        let correctVaporAPNSInstance = try VaporAPNS(authKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_T36248L7C8.p8")
        XCTAssertNotNil(correctVaporAPNSInstance)
    }
    
    func testSendPush() throws {
        let correctVaporAPNSInstance = try VaporAPNS(authKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_T36248L7C8.p8")
        
        let pushMessage = ApplePushMessage(topic: "nl.logicbit.ReviusSchoolkrant", priority: .immediately, payload: Dictionary(), deviceToken: "43e798c31a282d129a34d84472bbdd7632562ff0732b58a85a27c5d9fdf59b69", sandbox: true)
        
        let t = correctVaporAPNSInstance?.send(applePushMessage: pushMessage)
        print (t)
    }
}
