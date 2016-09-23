//
//  VaporAPNSPush.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 23/09/2016.
//
//

import Foundation

/// Apple Push Notification Message
public struct ApplePushMessage {
    /// Message Id
    public let messageId:String = UUID().uuidString
    
    /// Application BundleID
    public let topic: String
    
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
    
    /// APNS Payload aps {...}
    public let payload:Dictionary<String,Any>
    
    /// Device Token without <> and whitespaces
    public let deviceToken:String
    
    /// Use sandbox server URL or not
    public let sandbox:Bool
    
    /// Response Clousure
    public var responseBlock:((VaporAPNS.Result) -> ())?
    
    /// Network error Clousure
    public var networkError:((Error?)->())?
    
    public init(topic:String, priority:Priority, payload:Dictionary<String,Any>, deviceToken:String, sandbox:Bool = true) {
        self.topic = topic
        self.priority = priority
        self.payload = payload
        self.deviceToken = deviceToken
        self.sandbox = sandbox
    }
}
