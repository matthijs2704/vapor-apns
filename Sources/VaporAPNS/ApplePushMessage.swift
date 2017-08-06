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
public struct ApplePushMessage {
    /// Message ID
    public let messageId: String = UUID().uuidString
    
    public let topic: String?
    
    public let collapseIdentifier: String?

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
    
    /// Use sandbox server URL or not
    public let sandbox:Bool
    
    public init(topic: String? = nil, priority: Priority, expirationDate: Date? = nil, payload: Payload, sandbox:Bool = true, collapseIdentifier: String? = nil) {
        self.topic = topic
        self.priority = priority
        self.expirationDate = expirationDate
        self.payload = payload
        self.sandbox = sandbox
        self.collapseIdentifier = collapseIdentifier
    }
    
}
