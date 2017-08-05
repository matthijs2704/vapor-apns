//
//  Payload.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/10/2016.
//
//

import Foundation
import JSON
import Core

open class Payload: JSONRepresentable {
    /// The number to display as the badge of the app icon.
    public var badge: Int?
    
    /// A short string describing the purpose of the notification. Apple Watch displays this string as part of the notification interface. This string is displayed only briefly and should be crafted so that it can be understood quickly. This key was added in iOS 8.2.
    public var title: String?
    
    // A secondary description of the reason for the alert.
    public var subtitle: String?

    /// The text of the alert message. Can be nil if using titleLocKey
    public var body: String?
    
    /// The key to a title string in the Localizable.strings file for the current localization. The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the titleLocArgs array.
    public var titleLocKey: String?
    
    /// Variable string values to appear in place of the format specifiers in titleLocKey.
    public var titleLocArgs: [String]?
    
    /// If a string is specified, the system displays an alert that includes the Close and View buttons. The string is used as a key to get a localized string in the current localization to use for the right button’s title instead of “View”.
    public var actionLocKey: String?
    
    /// A key to an alert-message string in a Localizable.strings file for the current localization (which is set by the user’s language preference). The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the bodyLocArgs array.
    public var bodyLocKey: String?
    
    /// Variable string values to appear in place of the format specifiers in bodyLocKey.
    public var bodyLocArgs: [String]?
    
    /// The filename of an image file in the app bundle, with or without the filename extension. The image is used as the launch image when users tap the action button or move the action slider. If this property is not specified, the system either uses the previous snapshot, uses the image identified by the UILaunchImageFile key in the app’s Info.plist file, or falls back to Default.png.
    public var launchImage: String?
    
    /// The name of a sound file in the app bundle or in the Library/Sounds folder of the app’s data container. The sound in this file is played as an alert. If the sound file doesn’t exist or default is specified as the value, the default alert sound is played. 
    public var sound: String?

    /// a category that is used by iOS 10+ notifications
    public var category: String?
    
    /// Silent push notification. This automatically ignores any other push message keys (title, body, ect.) and only the extra key-value pairs are added to the final payload
    public var contentAvailable: Bool = false

    /// A Boolean indicating whether the payload contains content that can be modified by an iOS 10+ Notification Service Extension (media, encrypted content, ...) 
    public var hasMutableContent: Bool = false
    
    /// When displaying notifications, the system visually groups notifications with the same thread identifier together.
    public var threadId: String?

    // Any extra key-value pairs to add to the JSON
    public var extra: [String: NodeRepresentable] = [:]
    
    // Simple, empty initializer
    public init() {}
    
    open func makeJSON() throws -> JSON {
        var payloadData: [String: NodeRepresentable] = [:]
        var apsPayloadData: [String: NodeRepresentable] = [:]
        
        if contentAvailable {
            apsPayloadData["content-available"] = true
        }
            
        // Create alert dictionary
        var alert: [String: NodeRepresentable] = [:]
        
        if let title = title {
            alert["title"] = title
        }
        
        if let titleLocKey = titleLocKey {
            alert["title-loc-key"] = titleLocKey
            
            if let titleLocArgs = titleLocArgs {
                alert["title-loc-args"] = try titleLocArgs.makeNode(in: nil)
            }
        }
        
        if let subtitle = subtitle {
            alert["subtitle"] = subtitle
        }
        
        if let body = body {
            alert["body"] = body
        } else {
            if let bodyLocKey = bodyLocKey {
                alert["loc-key"] = bodyLocKey
                
                if let bodyLocArgs = bodyLocArgs {
                    alert["loc-args"] = try bodyLocArgs.makeNode(in: nil)
                }
            }
        }
        
        if let actionLocKey = actionLocKey {
            alert["action-loc-key"] = actionLocKey
        }
        
        if let launchImage = launchImage {
            alert["launch-image"] = launchImage
        }
        // Alert dictionary created
        
        apsPayloadData["alert"] = try alert.makeNode(in: nil)
        
        if let badge = badge {
            apsPayloadData["badge"] = badge
        }
        
        if let sound = sound {
            apsPayloadData["sound"] = sound
        }
        
        if let category = category {
            apsPayloadData["category"] = category
        }
        
        if hasMutableContent {
            apsPayloadData["mutable-content"] = 1
        }
        
        payloadData["aps"] = try apsPayloadData.makeNode(in: nil)
        for (key, value) in extra {
            payloadData[key] = value
        }
        
        let json = JSON(node: try payloadData.makeNode(in: nil))
        return json
    }
}

public extension Payload {
    public convenience init(message: String) {
        self.init()
        self.body = message
    }
    
    public convenience init(title: String, body: String) {
        self.init()
        self.title = title
        self.body = body
    }
    
    public convenience init(title: String, body: String, badge: Int) {
        self.init()
        self.title = title
        self.body = body
        self.badge = badge
    }
    
    
    /// A simple, already made, Content-Available payload
    public static var contentAvailable: Payload {
        let payload = Payload()
        payload.contentAvailable = true
        return payload
    }
}

extension Payload: Equatable {
    
    public static func ==(lhs: Payload, rhs: Payload) -> Bool {
        guard lhs.badge == rhs.badge else {
            return false
        }
        
        guard lhs.title == rhs.title else {
            return false
        }

        guard lhs.body == rhs.body else {
            return false
        }

        guard lhs.titleLocKey == rhs.titleLocKey else {
            return false
        }

        guard lhs.titleLocArgs != nil && rhs.titleLocArgs != nil && lhs.titleLocArgs! == rhs.titleLocArgs! else {
            return false
        }

        guard lhs.actionLocKey == rhs.actionLocKey else {
            return false
        }

        guard lhs.bodyLocKey == rhs.bodyLocKey else {
            return false
        }

        guard lhs.bodyLocArgs != nil && rhs.bodyLocArgs != nil && lhs.bodyLocArgs! == rhs.bodyLocArgs! else {
            return false
        }

        guard lhs.launchImage == rhs.launchImage else {
            return false
        }

        guard lhs.sound == rhs.sound else {
            return false
        }

        guard lhs.contentAvailable == rhs.contentAvailable else {
            return false
        }

        guard lhs.threadId == rhs.threadId else {
            return false
        }

//        guard lhs.extra == rhs.extra else {
//            return false
//        }

        return true
    }
    
}
