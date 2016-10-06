//
//  Result.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import Foundation

public enum Result {
    case success(apnsId:String, serviceStatus: ServiceStatus)
    case error(apnsId:String, error: APNSError)
    case networkError(apnsId:String, error: Error)
}

public enum ServiceStatus: Int, Error {
    case success
    case badRequest
    case badCertitficate
    case badMethod
    case deviceTokenIsNoLongerActive
    case badNotificationPayload
    case serverReceivedTooManyRequests
    case internalServerError
    case serverShutingDownOrUnavailable
    
    public init(responseStatusCode: Int) {
        switch responseStatusCode {
        case 400:
            self = .badRequest
        case 403:
            self = .badCertitficate
        case 405:
            self = .badMethod
        case 410:
            self = .deviceTokenIsNoLongerActive
        case 413:
            self = .badNotificationPayload
        case 429:
            self = .serverReceivedTooManyRequests
        case 500:
            self = .internalServerError
        case 503:
            self = .serverShutingDownOrUnavailable
        default:
            self = .success
        }
    }
}
