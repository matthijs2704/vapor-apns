//
//  APNSSettings.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 17/09/2016.
//
//

import Foundation
import Node

/// Specific configuration options to be passed to `VaporAPNS`
public struct Options: CustomStringConvertible, NodeInitializable {
    public enum Port: Int {
        case p443 = 443, p2197 = 2197
    }
    
    public var topic: String?
    public var port: Port = .p443
    public var expiry: Date?
    public var priority: Int?
    public var apnsId: String?
    public var development: Bool = true
    
    public init() { }
    
    public init(node: Node, in context: Context) throws {
        topic = node["topic"]?.string
        if let portRaw = node["port"]?.int, let port = Port(rawValue: portRaw) {
            self.port = port
        }
        if let expiryTimeSince1970 = node["date"]?.double {
            expiry = Date(timeIntervalSince1970: expiryTimeSince1970)
        }
        priority = node["priority"]?.int
        apnsId = node["apns-id"]?.string
        development = node["development"]?.bool ?? development
    }
    
    public var description: String {
        return
            "Topic \(topic)" +
            "\nPort \(port.rawValue)" +
            "\nExpiry \(expiry) \(expiry?.timeIntervalSince1970.rounded())" +
            "\nPriority \(priority)" +
            "\nAPNSID \(apnsId)" +
            "\nDevelopment \(development)"
    }
}
