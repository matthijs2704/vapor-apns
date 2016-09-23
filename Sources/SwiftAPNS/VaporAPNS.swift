import HTTP
import Transport
import Foundation
import SwiftString

public class VaporAPNS {
    private var httpClient: Client<TCPClientStream, Serializer<Request>, Parser<Response>>!
    private var options: Options!
    private var apnsAuthKey: String!
    
    public init?(authKeyPath: String, options: Options? = nil) throws {
        guard let tokenStr = tokenStringFor(authKeyPath: authKeyPath) else {
            print ("VaporAPNS -- AuthKey file invalid")
            return nil
        }
        self.apnsAuthKey = tokenStr
        
        self.options = options ?? Options()
        
        try connect()
    }
    
    private func connect() throws {
        httpClient = try Client<TCPClientStream, Serializer<Request>, Parser<Response>>.init(scheme: "https", host: self.hostURL(development: self.options.development), port: self.options.port.rawValue)
    }
    
    public func send(applePushMessage message: ApplePushMessage) throws {
        try httpClient.post(path: "/3/device/")
    }
    
}

extension VaporAPNS {
    
    fileprivate func hostURL(development: Bool) -> String {
        if development {
            return "api.development.push.apple.com" //   "
        } else {
            return "api.push.apple.com" //   /3/device/"
        }
    }
    
    fileprivate func tokenStringFor(authKeyPath: String) -> String? {
        guard let fileData = NSData(contentsOfFile: authKeyPath) as? Data else {
            return nil
        }
        
        guard let fileString = String(data: fileData, encoding: .utf8) else {
            return nil
        }
        
        guard let tokenString = fileString.collapseWhitespace().between("-----BEGIN PRIVATE KEY-----", "-----END PRIVATE KEY-----")?.trimmed() else {
            return nil
        }
        
        guard tokenString.characters.count == 200 else {
            return nil
        }
        
        return tokenString
    }
}
