//
//  APNSSettings.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 17/09/2016.
//
//

import Foundation
extension VaporAPNS {
    public struct Options: CustomStringConvertible {
        public enum Port: Int {
            case p443 = 443, p2197 = 2197
        }
        
        public var topic: String?
        public var port: Port = .p443
        public var expiry: NSDate?
        public var priority: Int?
        public var apnsId: String?
        public var development: Bool = true
        
        public init() {}
        
        public var description: String {
            return "Topic \(self.topic)" +
                "\nPort \(port.rawValue)" +
                "\nExpiry \(expiry) \(expiry?.timeIntervalSince1970.rounded())" +
                "\nPriority \(priority)" +
                "\nAPNSID \(apnsId)" +
            "\nDevelopment \(development)"
        }
    }
    
}
