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
    }
    
    func testSendPush() throws {
        let correctVaporAPNSInstance = try VaporAPNS(certPath: "/Users/matthijs/Downloads/newfile.crt.pem", keyPath: "/Users/matthijs/Downloads/newfile.key.pem")
        
        let pl = Payload(title: "Hello", body: "from here! :D")
        let pushMessage = ApplePushMessage(topic: "nl.logicbit.ReviusSchoolkrant", priority: .immediately, payload: pl, deviceToken: "488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7", sandbox: true)
        
        let t = correctVaporAPNSInstance.send(applePushMessage: pushMessage)
//        let t2 = correctVaporAPNSInstance.send(applePushMessage: pushMessage)
        print (t)
    }
}
