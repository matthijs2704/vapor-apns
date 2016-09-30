import HTTP
import Transport
import Foundation
import SwiftString
import JSON
import Vapor
import CCurl
import Jay
import JSON

public class VaporAPNS {
    private var options: Options
    
    private var httpClient: Client<TCPClientStream, Serializer<Request>, Parser<Response>>?
    private var curlHandle: UnsafeMutableRawPointer
    
    public init(certPath: String, keyPath: String, options: Options? = nil) throws {
        self.options = options ?? Options()
        self.curlHandle = curl_easy_init()
        
        curlHelperSetOptString(curlHandle, CURLOPT_SSLCERT, certPath)
        curlHelperSetOptString(curlHandle, CURLOPT_SSLCERTTYPE, "PEM")
        curlHelperSetOptString(curlHandle, CURLOPT_SSLKEY, keyPath)
        curlHelperSetOptString(curlHandle, CURLOPT_SSLKEYTYPE, "PEM")
        
        curlHelperSetOptInt(curlHandle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0)
        curlHelperSetOptBool(curlHandle, CURLOPT_VERBOSE, 1)
    }
    
    public func send(applePushMessage message: ApplePushMessage) -> Result {
        // Set URL
        let url = ("\(self.hostURL(development: message.sandbox))/3/device/\(message.deviceToken)")
        curlHelperSetOptString(curlHandle, CURLOPT_URL, url)
        
        // force set port to 443
        curlHelperSetOptInt(curlHandle, CURLOPT_PORT, 443)
        
        // Follow location
        curlHelperSetOptBool(curlHandle, CURLOPT_FOLLOWLOCATION, 1)
        
        // set POST request
        curlHelperSetOptBool(curlHandle, CURLOPT_POST, 1)
        
        // setup payload
        // TODO: Message payload
        let json = try! JSON(node: [
            "aps": [
                "alert": "hi",
                "sound":"default"
            ]
            ])
        
        let str = try! String(bytes: try! json.makeBytes())
        print(str)
        
        curlHelperSetOptString(curlHandle, CURLOPT_POSTFIELDS, str)

        
        // Tell CURL to add headers
        curlHelperSetOptBool(curlHandle, CURLOPT_HEADER, 1)
        
        //Headers
        let headers = self.requestHeaders(for: message)
        var curlHeaders: UnsafeMutablePointer<curl_slist>?
        curlHeaders = curl_slist_append(curlHeaders, "Accept: application/json")
        curlHeaders = curl_slist_append(curlHeaders, "Content-Type: application/json")
        for header in headers {
            curlHeaders = curl_slist_append(curlHeaders, "\(header.key): \(header.value)")
        }
        curl_slist_append(curlHeaders, "Content-Length: \(str.count)")
        curl_slist_append(curlHeaders, "User-Agent: curl/7.50.3")

        curlHelperSetOptList(curlHandle, CURLOPT_HTTPHEADER, curlHeaders)
        
        // Get response
        var writeStorage = WriteStorage()
        curlHelperSetOptWriteFunc(curlHandle, &writeStorage) { (ptr, size, nMemb, privateData) -> Int in
            let storage = privateData?.assumingMemoryBound(to: WriteStorage.self)
            let realsize = size * nMemb
            
            var bytes: [UInt8] = [UInt8](repeating: 0, count: realsize)
            memcpy(&bytes, ptr, realsize)
            
            for byte in bytes {
                storage?.pointee.data.append(byte)
            }
            return realsize
        }
        
        let ret = curl_easy_perform(curlHandle)
        
        //        print("ret = \(ret)")
        
        if ret == CURLE_OK {
            // Create string from Data
            let str = String.init(data: writeStorage.data, encoding: .utf8)!
            print ("Raw string \(str)")
            
            // Split into two pieces by '\r\n\r\n' as the response has two newlines before the returned data. This causes us to have two pieces, the headers/crap and the server returned data
            let splittedString = str.components(separatedBy: "\r\n\r\n")
            
            let result: Result!
            
            // Ditch the first part and only get the useful data part
            let responseData = splittedString[1]
            
            if responseData != "" {
                // Get JSON from loaded data string
                let json = try! Jay.init(formatting: .minified).jsonFromData(responseData.toBytes())
                
                if (json.dictionary?.keys.contains("reason"))! {
                    result = Result.error(apnsId: message.messageId, error: APNSError.init(errorReason: json.dictionary!["reason"]!.string!))
                }else {
                    result = Result.success(apnsId: message.messageId, serviceStatus: .success)
                }
                
            }else {
                result = Result.success(apnsId: message.messageId, serviceStatus: .success)
            }
            
            // Do some cleanup
//            curl_easy_cleanup(curlHandle)
            curl_slist_free_all(curlHeaders!)
            
            return result
        } else {
            let error = curl_easy_strerror(ret)
            let errorString = String(utf8String: error!)!
            
//            curl_easy_cleanup(curlHandle)
            curl_slist_free_all(curlHeaders!)
            
            // todo: Better unknown error handling?
            return Result.error(apnsId: message.messageId, error: APNSError.unknownError(error: errorString))
            
        }
    }
    
    private func requestHeaders(for message: ApplePushMessage) -> [String: String] {
        var headers: [String : String] = [
//            "apns-id": message.messageId,
//            "apns-expiration": "\(Int(message.expirationDate?.timeIntervalSince1970.rounded() ?? 0))",
//            "apns-priority": "\(message.priority.rawValue)",
            "apns-topic": message.topic
        ]
        
        if let collapseId = message.collapseIdentifier {
            headers["apns-collapse-id"] = collapseId
        }
        
        if let threadId = message.threadIdentifier {
            headers["thread-id"] = threadId
        }
        
        return headers
        
    }
    
    private class WriteStorage {
        var data = Data()
    }
}

extension VaporAPNS {
    fileprivate func hostURL(development: Bool) -> String {
        if development {
            return "https://api.development.push.apple.com" //   "
        } else {
            return "https://api.push.apple.com" //   /3/device/"
        }
    }
}
