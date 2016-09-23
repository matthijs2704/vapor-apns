import HTTP
import Transport
import Foundation
import SwiftString

public class VaporAPNS {
    private var httpClient: Client<TCPClientStream, Serializer<Request>, Parser<Response>>!
    private var options: Options!
    private var apnsAuthKey: String!
    
    public init?(authKeyPath: String) {
        guard let tokenStr = tokenStringFor(authKeyPath: authKeyPath) else {
            print ("VaporAPNS -- AuthKey file invalid")
            return nil
        }
        self.apnsAuthKey = tokenStr
    }
    
    
    
    
    
}

extension VaporAPNS {
    
    private func baseURL(development: Bool, port: Options.Port) -> NSURL {
        if development {
            return NSURL(string: "https://api.development.push.apple.com:\(port)/3/device/")!
        } else {
            return NSURL(string: "https://api.push.apple.com:\(port)/3/device/")!
        }
    }
    
    func tokenStringFor(authKeyPath: String) -> String? {
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
