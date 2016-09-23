//
//  Result.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import Foundation

extension VaporAPNS {
    public enum Result {
        case success(apnsId:String?, serviceStatus: ServiceStatus)
        case error(apnsId:String?, error: APNSError)
    }
    
    public enum ServiceStatus: Error {
        case success
        case badRequest
        case badCertitficate
        case badMethod
        case deviceTokenIsNoLongerActive
        case badNotificationPayload
        case serverReceivedTooManyRequests
        case internalServerError
        case serverShutingDownOrUnavailable
        
        public static func statusCodeFrom(responseStatusCode: Int) -> ServiceStatus {
            switch responseStatusCode {
            case 400:
                return .badRequest
            case 403:
                return .badCertitficate
            case 405:
                return .badMethod
            case 410:
                return .deviceTokenIsNoLongerActive
            case 413:
                return .badNotificationPayload
            case 429:
                return .serverReceivedTooManyRequests
            case 500:
                return .internalServerError
            case 503:
                return .serverShutingDownOrUnavailable
            default: return .success
            }
        }
    }
}
