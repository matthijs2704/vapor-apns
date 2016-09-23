//
//  APNSError.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 17/09/2016.
//
//

import Foundation
public extension VaporAPNS {
    public enum APNSError: String, CustomStringConvertible {
        case payloadEmpty
        case payloadTooLarge
        case badTopic
        case topicDisallowed
        case badMessageId
        case badExpirationDate
        case badPriority
        case missingDeviceToken
        case badDeviceToken
        case deviceTokenNotForTopic
        case unregistered
        case duplicateHeaders
        case badCertificateEnvironment
        case badCertificate
        case forbidden
        case badPath
        case methodNotAllowed
        case tooManyRequests
        case idleTimeout
        case shutdown
        case internalServerError
        case serviceUnavailable
        case missingTopic
        
        public var description: String {
            switch self {
            case .payloadEmpty: return "The message payload was empty."
            case .payloadTooLarge: return "The message payload was too large. The maximum payload size is 4096 bytes."
            case .badTopic: return "The apns-topic was invalid."
            case .topicDisallowed: return "Pushing to this topic is not allowed."
            case .badMessageId: return "The apns-id value is bad."
            case .badExpirationDate: return "The apns-expiration value is bad."
            case .badPriority: return "The apns-priority value is bad."
            case .missingDeviceToken: return "The device token is not specified in the request :path. Verify that the :path header contains the device token."
            case .badDeviceToken: return "The specified device token was bad. Verify that the request contains a valid token and that the token matches the environment."
            case .deviceTokenNotForTopic: return "The device token does not match the specified topic."
            case .unregistered: return "The device token is inactive for the specified topic."
            case .duplicateHeaders: return "One or more headers were repeated."
            case .badCertificateEnvironment: return "The client certificate was for the wrong environment."
            case .badCertificate: return "The certificate was bad."
            case .forbidden: return "The specified action is not allowed."
            case .badPath: return "The request contained a bad :path value."
            case .methodNotAllowed: return "The specified :method was not POST."
            case .tooManyRequests: return "Too many requests were made consecutively to the same device token."
            case .idleTimeout: return "Idle time out."
            case .shutdown: return "The server is shutting down."
            case .internalServerError: return "An internal server error occurred."
            case .serviceUnavailable: return "The service is unavailable."
            case .missingTopic: return "The apns-topic header of the request was not specified and was required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics."
            }
        }
    }
}
