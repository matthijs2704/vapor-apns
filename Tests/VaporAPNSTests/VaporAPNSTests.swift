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

import CLibreSSL
import Core

class VaporAPNSTests: XCTestCase { // TODO: Set this up so others can test this 😉
    
    let vaporAPNS: VaporAPNS! = nil
    
    override func setUp() {
        print ("Hi")
    }
    
    func testInitializer() throws {
    }
    
    func testSendPush() throws {
        let options = try! Options(topic: "nl.logicbit.ReviusSchoolkrant", teamId: "YQ3FQN6Z53", keyId: "4K8N6Q55G7", keyPath: "/Users/matthijs/Downloads/APNSAuthKey_4K8N6Q55G7_form.p8")
//        let options = try! Options(topic: "nl.logicbit.ReviusSchoolkrant", certPath: "/Users/matthijs/Downloads/newfile.crt.pem", keyPath: "/Users/matthijs/Downloads/newfile.key.pem")
        let correctVaporAPNSInstance = try! VaporAPNS(options: options)

        let pl = Payload(title: "Hello", body: "from here! :D")
        let pushMessage = ApplePushMessage(topic: "nl.logicbit.ReviusSchoolkrant", priority: .immediately, payload: pl, deviceToken: "488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7", sandbox: true)
        
        let t = correctVaporAPNSInstance.send(applePushMessage: pushMessage)
//        let t2 = correctVaporAPNSInstance.send(applePushMessage: pushMessage)
        print (t)
    }
    
    func testLoadP8() {
        var pKey = EVP_PKEY_new()
        
        let fp = fopen("/Users/matthijs/Downloads/APNSAuthKey_4K8N6Q55G7_form.p8", "r")
        
        PEM_read_PrivateKey(fp, &pKey, nil, nil)
        
        fclose(fp)
        
        let ecKey = EVP_PKEY_get1_EC_KEY(pKey)
        
        EC_KEY_set_conv_form(ecKey, POINT_CONVERSION_UNCOMPRESSED)
        
        let bn = EC_KEY_get0_private_key(ecKey!)
        let thing = BN_bn2hex(bn)
        
        let privateKey = String.init(validatingUTF8: thing!)
        
        print ("00\(privateKey)")

        }
}
