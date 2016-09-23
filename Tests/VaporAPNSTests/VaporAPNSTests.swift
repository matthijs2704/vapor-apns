//
//  VaporAPNSTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import XCTest
@testable import VaporAPNS

class VaporAPNSTests: XCTestCase {
    
    let vaporAPNS: VaporAPNS! = nil
    
    override func setUp() {
        print ("Hi")
    }
    
    func testInitializer() {
        let wrongVaporAPNSInstance = VaporAPNS(authKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_T36248L7C8.p9")
        XCTAssertNil(wrongVaporAPNSInstance)
        
        let correctVaporAPNSInstance = VaporAPNS(authKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_T36248L7C8.p8")
        XCTAssertNotNil(correctVaporAPNSInstance)
        
    }
}
