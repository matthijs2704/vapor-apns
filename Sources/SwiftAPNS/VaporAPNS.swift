import HTTP
import Transport
import Foundation
import SwiftString
import JSON
import Vapor
import CCurl

public class VaporAPNS {
    private var httpClient: Client<TCPClientStream, Serializer<Request>, Parser<Response>>!
    private var options: Options!
    fileprivate var apnsAuthKey: String!
    private var curlHandle: UnsafeMutableRawPointer!

    public init?(authKeyPath: String, options: Options? = nil) throws {
        self.options = options ?? Options()
        
        guard let tokenStr = tokenStringFor(authKeyPath: authKeyPath) else {
            print ("VaporAPNS -- AuthKey file invalid")
            return nil
        }
        self.apnsAuthKey = tokenStr
        
        curlHandle = curl_easy_init()
        curlHelperSetOptInt(curlHandle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0)
    }
    
    private func connect() throws {
        // Force Curl to HTTP/2 mode

//        httpClient = try Client<TCPClientStream, Serializer<Request>, Parser<Response>>.init(scheme: "https", host: self.hostURL(development: self.options.development), port: self.options.port.rawValue, securityLayer: .tls(nil))
//        sock = try TLS.Socket(mode: .client, hostname: self.hostURL(development: self.options.development), port: UInt16(self.options.port.rawValue))
//        try sock.connect(servername: self.hostURL(development: self.options.development))
////        let t = try sock.receive()
//        print (t)
    }
    
    public func send(applePushMessage message: ApplePushMessage) -> Result {
//        do {
            let headers = self.requestHeaders(for: message)
            var headersList: UnsafeMutablePointer<curl_slist>?
            
            // set url for push according env
            curlHelperSetOptString(curlHandle, CURLOPT_URL, ("\(self.hostURL(development: message.sandbox))/3/device/\(message.deviceToken)"))
            
            // set port to 443 (we can omit it)
            curlHelperSetOptInt(curlHandle, CURLOPT_PORT, 443)
            
            // follow location
            curlHelperSetOptBool(curlHandle, CURLOPT_FOLLOWLOCATION, 1)
            
            // set POST request
            curlHelperSetOptBool(curlHandle, CURLOPT_POST, 1)
            
            // setup payload
            // TODO: Message payload
//            guard let jsonString = message.payload.toString() else { return }
//            let payload = jsonString
            
            curlHelperSetOptString(curlHandle, CURLOPT_POSTFIELDS, "")
            
            // set headers
            curlHelperSetOptBool(curlHandle, CURLOPT_HEADER, 1)
            // TODO: Headers

            headersList = curl_slist_append(headersList, "Accept: application/json")
            headersList = curl_slist_append(headersList, "Content-Type: application/json")
            for header in headers {
                headersList = curl_slist_append(headersList, "\(header.name): \(header.value)")
            }
            
            curlHelperSetOptList(curlHandle, CURLOPT_HTTPHEADER, headersList)
            
            // TODO: improve response handler
            let ret = curl_easy_perform(curlHandle)
            
            print("ret = \(ret)")
            
            if ret == CURLE_OK {
//                print(String(utf8String: error!)!)
            } else {
                let error = curl_easy_strerror(ret)
                print(String(utf8String: error!)!)
            }
//            let response = try httpClient.post(path: "/3/device/\(message.deviceToken)", headers: headers)
//            print (response.json)
            return Result.success(apnsId: message.messageId, serviceStatus: .success)
//        } catch {
//            return Result.networkError(apnsId: message.messageId, error: error)
//        }
    }
   
    private func requestHeaders(for message: ApplePushMessage) -> [Header] {
        var headers: [String : String] = [
            "authorization": "bearer \(apnsAuthKey)",
            "apns-id": message.messageId,
            "apns-expiration": "\(message.expirationDate?.timeIntervalSince1970.rounded() ?? 0)",
            "apns-priority": "\(message.priority.rawValue)",
            "apns-topic": message.topic
        ]

        if let collapseId = message.collapseIdentifier {
            headers["apns-collapse-id"] = collapseId
        }
        
        if let threadId = message.threadIdentifier {
            headers["thread-id"] = threadId
        }
        
        var headerss: [Header] = []
        for (key, value) in headers {
            headerss.append((key, value))
        }
       
        return headerss
    
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
