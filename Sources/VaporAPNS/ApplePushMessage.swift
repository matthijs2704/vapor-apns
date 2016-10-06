//
//  VaporAPNSPush.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import Foundation
import JSON

/// Apple Push Notification Message
public struct ApplePushMessage: NodeRepresentable {
    /// Called when there was a response from the server
    public typealias ResponseCallback = (Result) -> Void
    
    /// Called when there was an error
    public typealias ErrorCallback = (Error) -> Void
    
    /// Message ID
    public let messageId: String = UUID().uuidString
    
    /// Application BundleID
    public let topic: String
    
    public let collapseIdentifier: String?

    public let threadIdentifier: String?

    public let expirationDate: Date?
    
    /// APNS Priority
    public let priority: Priority
    
    /// Push notification delivery priority
    ///
    /// - energyEfficient: Send the push message at a time that takes into account power considerations for the device.
    /// - immediately:     Send the push message immediately. Notifications with this priority must trigger an alert, sound, or badge on the target device. It is an error to use this priority for a push notification that contains only the content-available key.
    public enum Priority: Int {
        case energyEfficient = 5
        case immediately = 10
    }
    
    /// APNS Payload
    public let payload: Payload
    
    /// Device Token without <> and whitespaces
    public let deviceToken:String
    
    /// Use sandbox server URL or not
    public let sandbox:Bool
    
    /// Response Clousure
    public var responseCallback: ResponseCallback?
    
    /// Network error Clousure
    public var networkError: ErrorCallback?
    
    public init(topic: String, priority: Priority, expirationDate: Date? = nil, payload: Payload, deviceToken:String, sandbox:Bool = true, collapseIdentifier: String? = nil, threadIdentifier: String? = nil) {
        self.topic = topic
        self.priority = priority
        self.expirationDate = expirationDate
        self.payload = payload
        self.deviceToken = deviceToken
        self.sandbox = sandbox
        self.collapseIdentifier = collapseIdentifier
        self.threadIdentifier = threadIdentifier
    }
    
    public func makeNode(context ntext: Context) throws -> Node {
        return EmptyNode
    }
}
