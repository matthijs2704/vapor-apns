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
    
    public var topic: String
    public var port: Port = .p443
    
    // Authentication method: certificates
    public var certPath: String?
    public var keyPath: String?
    
    // Authentication method: authentication key
    public var teamId: String?
    public var keyId: String?
    public var privateKey: String?
    public var publicKey: String?

    public var debugLogging: Bool = false
    
    public var disableCurlCheck: Bool = false
    public var forceCurlInstall: Bool = false
    
    public var usesCertificateAuthentication: Bool {
        return certPath != nil && keyPath != nil
    }
    
    public init(topic: String, certPath: String, keyPath: String, port: Port = .p443, debugLogging: Bool = false) throws {
        self.topic = topic
        self.certPath = certPath
        self.keyPath = keyPath
        
        self.debugLogging = debugLogging
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: certPath) else {
            throw InitializeError.certificateFileDoesNotExist
        }
        guard fileManager.fileExists(atPath: keyPath) else {
            throw InitializeError.keyFileDoesNotExist
        }
    }
    
    public init(topic: String, teamId: String, keyId: String, keyPath: String, port: Port = .p443, debugLogging: Bool = false) throws {
        self.teamId = teamId
        self.topic = topic
        self.keyId = keyId
        
        self.debugLogging = debugLogging
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: keyPath) else {
            throw InitializeError.keyFileDoesNotExist
        }
        
        let (priv, pub) = try keyPath.tokenString()
        self.privateKey = priv
        self.publicKey = pub
    }
    
    
    /// EXPERT: Initializer to use when you are unable to use the filesystem and you want to pass the final private key/public key as a String. Warning: This is only for advanced users, as there is a big chance the key is wrong and if so your notifications can not be sent.
    ///
    /// - parameter topic:        Topic of the notifications (your app's bundle id)
    /// - parameter teamId:       Team identifier
    /// - parameter keyId:        KeyID provided on Apple's Developer Portal
    /// - parameter rawPrivKey:   String of the final raw privateKey
    /// - parameter rawPubKey:    String of the final raw publicKey, can be "", but will cause an (non-fatal) error/warning every time a notification is sent
    /// - parameter port:         Port of the APNS servers to use. Useful if a port is blocked by your ISP. Defaults to port 443
    /// - parameter debugLogging: Enable debug logging
    ///
    /// - throws: Nothing
    ///
    /// - returns: Instance of Options
    public init(topic: String, teamId: String, keyId: String, rawPrivKey: String, rawPubKey: String, port: Port = .p443, debugLogging: Bool = false) throws {
        self.teamId = teamId
        self.topic = topic
        self.keyId = keyId

        self.debugLogging = debugLogging
        
        self.privateKey = rawPrivKey
        self.publicKey = rawPubKey
    }

    
    public init(node: Node) throws {
        guard let topic = node["topic"]?.string else {
            throw InitializeError.noTopic
        }
        self.topic = topic
        
        if let portRaw = node["port"]?.int, let port = Port(rawValue: portRaw) {
            self.port = port
        }
        
        var hasAuthentication = false
        
        if let privateKeyLocation = node["keyPath"]?.string, let keyId = node["keyId"]?.string {
            hasAuthentication = true
            let (priv, pub) = try privateKeyLocation.tokenString()
            self.privateKey = priv
            self.publicKey = pub
            self.keyId = keyId
        }

        if let certPath = node["certificatePath"]?.string, let keyPath = node["keyPath"]?.string {
            if hasAuthentication {
                print ("You've seem to have specified both authentication methods, choosing preferred APNS Auth Key method...")
            } else {
                hasAuthentication = true
                self.certPath = certPath
                self.keyPath = keyPath
            }
        }
        
        guard hasAuthentication else {
            throw InitializeError.noAuthentication
        }
    }
    
    public var description: String {
        return
            "Topic \(topic)" +
                "\nPort \(port.rawValue)" +
                "\nPort \(port.rawValue)" +
                "\nCER - Certificate path: \(String(describing: certPath))" +
                "\nCER - Key path: \(String(describing: keyPath))" +
                "\nTOK - Key ID: \(String(describing: keyId))" +
                "\nTOK - Private key: \(String(describing: privateKey))" +
                "\nTOK - Public key: \(String(describing: publicKey))"
    }
}
