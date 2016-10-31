//
//  ErrorTests.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 09/10/2016.
//
//

import Foundation
import XCTest
@testable import VaporAPNS

class ErrorTests: XCTestCase {
    
    func testPayloadEmptyError() {
        let error = APNSError.init(errorReason: "PayloadEmpty")
        if case .payloadEmpty = error {
            XCTAssertEqual(error.description, "The message payload was empty.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testPayloadTooLargeError() {
        let error = APNSError.init(errorReason: "PayloadTooLarge")
        if case .payloadTooLarge = error {
            XCTAssertEqual(error.description, "The message payload was too large. The maximum payload size is 4096 bytes.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadTopicError() {
        let error = APNSError.init(errorReason: "BadTopic")
        if case .badTopic = error {
            XCTAssertEqual(error.description, "The apns-topic was invalid.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testTopicDisallowedError() {
        let error = APNSError.init(errorReason: "TopicDisallowed")
        if case .topicDisallowed = error {
            XCTAssertEqual(error.description, "Pushing to this topic is not allowed.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadMessageIdError() {
        let error = APNSError.init(errorReason: "BadMessageId")
        if case .badMessageId = error {
            XCTAssertEqual(error.description, "The apns-id value is bad.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    
    func testBadExpirationDateError() {
        let error = APNSError.init(errorReason: "BadExpirationDate")
        if case .badExpirationDate = error {
            XCTAssertEqual(error.description, "The apns-expiration value is bad.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadPriorityError() {
        let error = APNSError.init(errorReason: "BadPriority")
        if case .badPriority = error {
            XCTAssertEqual(error.description, "The apns-priority value is bad.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testMissingDeviceTokenError() {
        let error = APNSError.init(errorReason: "MissingDeviceToken")
        if case .missingDeviceToken = error {
            XCTAssertEqual(error.description, "The device token is not specified in the request :path. Verify that the :path header contains the device token.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadDeviceTokenError() {
        let error = APNSError.init(errorReason: "BadDeviceToken")
        if case .badDeviceToken = error {
            XCTAssertEqual(error.description, "The specified device token was bad. Verify that the request contains a valid token and that the token matches the environment.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testDeviceTokenNotForTopicError() {
        let error = APNSError.init(errorReason: "DeviceTokenNotForTopic")
        if case .deviceTokenNotForTopic = error {
            XCTAssertEqual(error.description, "The device token does not match the specified topic.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testUnregisteredError() {
        let error = APNSError.init(errorReason: "Unregistered")
        if case .unregistered = error {
            XCTAssertEqual(error.description, "The device token is inactive for the specified topic.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testDuplicateHeadersError() {
        let error = APNSError.init(errorReason: "DuplicateHeaders")
        if case .duplicateHeaders = error {
            XCTAssertEqual(error.description, "One or more headers were repeated.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadCertificateEnvironmentError() {
        let error = APNSError.init(errorReason: "BadCertificateEnvironment")
        if case .badCertificateEnvironment = error {
            XCTAssertEqual(error.description, "The client certificate was for the wrong environment.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadCertificateError() {
        let error = APNSError.init(errorReason: "BadCertificate")
        if case .badCertificate = error {
            XCTAssertEqual(error.description, "The certificate was bad.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testForbiddenError() {
        let error = APNSError.init(errorReason: "Forbidden")
        if case .forbidden = error {
            XCTAssertEqual(error.description, "The specified action is not allowed.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testBadPathError() {
        let error = APNSError.init(errorReason: "BadPath")
        if case .badPath = error {
            XCTAssertEqual(error.description, "The request contained a bad :path value.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testMethodNotAllowedError() {
        let error = APNSError.init(errorReason: "MethodNotAllowed")
        if case .methodNotAllowed = error {
            XCTAssertEqual(error.description, "The specified :method was not POST.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testTooManyRequestsError() {
        let error = APNSError.init(errorReason: "TooManyRequests")
        if case .tooManyRequests = error {
            XCTAssertEqual(error.description, "Too many requests were made consecutively to the same device token.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testIdleTimeoutError() {
        let error = APNSError.init(errorReason: "IdleTimeout")
        if case .idleTimeout = error {
            XCTAssertEqual(error.description, "Idle time out.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testShutdownError() {
        let error = APNSError.init(errorReason: "Shutdown")
        if case .shutdown = error {
            XCTAssertEqual(error.description, "The server is shutting down.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testInternalServerErrorError() {
        let error = APNSError.init(errorReason: "InternalServerError")
        if case .internalServerError = error {
            XCTAssertEqual(error.description, "An internal server error occurred.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testServiceUnavailableError() {
        let error = APNSError.init(errorReason: "ServiceUnavailable")
        if case .serviceUnavailable = error {
            XCTAssertEqual(error.description, "The service is unavailable.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testMissingTopicError() {
        let error = APNSError.init(errorReason: "MissingTopic")
        if case .missingTopic = error {
            XCTAssertEqual(error.description, "The apns-topic header of the request was not specified and was required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testInvalidSignatureError() {
        let error = APNSError.invalidSignature
        if case .invalidSignature = error {
            XCTAssertEqual(error.description, "The used signature may be wrong or something went wrong while signing. Double check the signing key and or try again.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testUnknownErrorError() {
        let error = APNSError.init(errorReason: "ApplesUnknownError")
        if case let .unknownError(errorMsg) = error {
            XCTAssertEqual(error.description, "This error has not been mapped yet in APNSError: ApplesUnknownError")
            XCTAssertEqual(errorMsg, "ApplesUnknownError")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    // MARK: InitializeError tests
    func testNoAuthenticationError() {
        let error = InitializeError.noAuthentication
        if case .noAuthentication = error {
            XCTAssertEqual(error.description, "APNS Authentication is required. You can either use APNS Auth Key authentication (easiest to setup and maintain) or the old fashioned certificates way")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testNoTopicError() {
        let error = InitializeError.noTopic
        if case .noTopic = error {
            XCTAssertEqual(error.description, "No APNS topic provided. This is required.")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testCertificateFileDoesNotExistError() {
        let error = InitializeError.certificateFileDoesNotExist
        if case .certificateFileDoesNotExist = error {
            XCTAssertEqual(error.description, "Certificate file could not be found on your disk. Double check if the file exists and if the path is correct")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
    
    func testKeyFileDoesNotExistError() {
        let error = InitializeError.keyFileDoesNotExist
        if case .keyFileDoesNotExist = error {
            XCTAssertEqual(error.description, "Key file could not be found on your disk. Double check if the file exists and if the path is correct")
        }else{
            XCTFail("APNSError didn't return the right error")
        }
    }
}
