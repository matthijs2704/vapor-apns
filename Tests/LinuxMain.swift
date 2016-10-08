//
//  LinuxMain.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 08/10/2016.
//
//

import XCTest
@testable import VaporAPNSTests

XCTMain([
    testCase(VaporAPNSTests.allTests),
    testCase(PayloadTests.allTests)
    ])
