import Foundation
import SwiftString
import JSON
import CCurl
import JSON
import JWT
import Console

open class VaporAPNS {
    fileprivate var options: Options
    
    fileprivate var curlHandle: UnsafeMutableRawPointer
    
    public init(options: Options) throws {
        self.options = options
        
        if !options.disableCurlCheck {
            if options.forceCurlInstall {
                let curlupdater = CurlUpdater()
                curlupdater.updateCurl()
            } else {
                let curlVersionChecker = CurlVersionHelper()
                curlVersionChecker.checkVersion()
            }
        }
        
        
        self.curlHandle = curl_easy_init()
    
        curlHelperSetOptBool(curlHandle, CURLOPT_VERBOSE, options.debugLogging ? CURL_TRUE : CURL_FALSE)

        if self.options.usesCertificateAuthentication {
            curlHelperSetOptString(curlHandle, CURLOPT_SSLCERT, options.certPath)
            curlHelperSetOptString(curlHandle, CURLOPT_SSLCERTTYPE, "PEM")
            curlHelperSetOptString(curlHandle, CURLOPT_SSLKEY, options.keyPath)
            curlHelperSetOptString(curlHandle, CURLOPT_SSLKEYTYPE, "PEM")
        }
        
        curlHelperSetOptInt(curlHandle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0)
    }
    
    open func send(_ message: ApplePushMessage, to deviceToken: String) -> Result {
        // Set URL
        let url = ("\(self.hostURL(message.sandbox))/3/device/\(deviceToken)")
        curlHelperSetOptString(curlHandle, CURLOPT_URL, url)
        
        // force set port to 443
        curlHelperSetOptInt(curlHandle, CURLOPT_PORT, options.port.rawValue)
        
        // Follow location
        curlHelperSetOptBool(curlHandle, CURLOPT_FOLLOWLOCATION, CURL_TRUE)
        
        // set POST request
        curlHelperSetOptBool(curlHandle, CURLOPT_POST, CURL_TRUE)
        
        // setup payload
        // TODO: Message payload
        
        var postFieldsString = toNullTerminatedUtf8String(try! message.payload.makeJSON().serialize(prettyPrint: false))!

        postFieldsString.withUnsafeMutableBytes() { (t: UnsafeMutablePointer<Int8>) -> Void in
            curlHelperSetOptString(curlHandle, CURLOPT_POSTFIELDS, t)
        }
        curlHelperSetOptInt(curlHandle, CURLOPT_POSTFIELDSIZE, postFieldsString.count)

        // Tell CURL to add headers
        curlHelperSetOptBool(curlHandle, CURLOPT_HEADER, CURL_TRUE)
        
        //Headers
        let headers = self.requestHeaders(for: message)
        var curlHeaders: UnsafeMutablePointer<curl_slist>?
        if !options.usesCertificateAuthentication {
            let privateKey = options.privateKey!.bytes.base64Decoded
            let claims: [Claim] = [
                IssuerClaim(string: options.teamId!),
                IssuedAtClaim()
            ]
            let jwt = try! JWT(additionalHeaders: [KeyID(options.keyId!)],
                               payload: JSON(claims),
                               signer: ES256(key: privateKey))

            let tokenString = try! jwt.createToken()

            let publicKey = options.publicKey!.bytes.base64Decoded
            
            do {
                let jwt2 = try JWT(token: tokenString)
                do {
                    try jwt2.verifySignature(using: ES256(key: publicKey))
                } catch {
                    // If we fail here, its an invalid signature
//                    return Result.error(apnsId: message.messageId, deviceToken: deviceToken, error: .invalidSignature)
                }
                
            } catch {
                print ("Couldn't verify token. This is a non-fatal error, we'll try to send the notification anyway.")
                if options.debugLogging {
                    print("\(error)")
                }
            }
            
            curlHeaders = curl_slist_append(curlHeaders, "Authorization: bearer \(tokenString.replacingOccurrences(of: " ", with: ""))")
        }
        curlHeaders = curl_slist_append(curlHeaders, "User-Agent: VaporAPNS/1.0.1")
        for header in headers {
            curlHeaders = curl_slist_append(curlHeaders, "\(header.key): \(header.value)")
        }
        curlHeaders = curl_slist_append(curlHeaders, "Accept: application/json")
        curlHeaders = curl_slist_append(curlHeaders, "Content-Type: application/json");
        curlHelperSetOptList(curlHandle, CURLOPT_HTTPHEADER, curlHeaders)
        
        // Get response
        var writeStorage = WriteStorage()
        curlHelperSetOptWriteFunc(curlHandle, &writeStorage) { (ptr, size, nMemb, privateData) -> Int in
            let storage = privateData?.assumingMemoryBound(to: WriteStorage.self)
            let realsize = size * nMemb
            
            var bytes: [UInt8] = [UInt8](repeating: 0, count: realsize)
            memcpy(&bytes, ptr!, realsize)
            
            for byte in bytes {
                storage?.pointee.data.append(byte)
            }
            return realsize
        }
        
        let ret = curl_easy_perform(curlHandle)
                
        if ret == CURLE_OK {
            // Create string from Data
            let str = String.init(data: writeStorage.data, encoding: .utf8)!
            
            // Split into two pieces by '\r\n\r\n' as the response has two newlines before the returned data. This causes us to have two pieces, the headers/crap and the server returned data
            let splittedString = str.components(separatedBy: "\r\n\r\n")
            
            let result: Result!
            
            // Ditch the first part and only get the useful data part
            let responseData = splittedString[1]
            
            if responseData != "" {
                // Get JSON from loaded data string
                let jsonNode = JSON(.bytes(responseData.makeBytes()), in: nil).makeNode(in: nil)
                if let reason = jsonNode["reason"]?.string {
                    result = Result.error(apnsId: message.messageId, deviceToken: deviceToken, error: APNSError.init(errorReason: reason))
                } else {
                    result = Result.success(apnsId: message.messageId, deviceToken: deviceToken, serviceStatus: .success)
                }
            } else {
                result = Result.success(apnsId: message.messageId, deviceToken: deviceToken, serviceStatus: .success)
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
            return Result.networkError(error: SimpleError.string(message: errorString))
        }
    }
    
    open func send(_ message: ApplePushMessage, to deviceTokens: [String], perDeviceResultHandler: ((_ result: Result) -> Void)) {
        for deviceToken in deviceTokens {
            let result = self.send(message, to: deviceToken)
            perDeviceResultHandler(result)
        }
    }
    
    open func toNullTerminatedUtf8String(_ str: [UTF8.CodeUnit]) -> Data? {
//        let cString = str.cString(using: String.Encoding.utf8)
        return str.withUnsafeBufferPointer() { buffer -> Data? in
            return buffer.baseAddress != nil ? Data(bytes: buffer.baseAddress!, count: buffer.count) : nil
        }
    }
    
    fileprivate func requestHeaders(for message: ApplePushMessage) -> [String: String] {
        var headers: [String : String] = [
            "apns-id": message.messageId,
            "apns-expiration": "\(Int(message.expirationDate?.timeIntervalSince1970.rounded() ?? 0))",
            "apns-priority": "\(message.priority.rawValue)",
            "apns-topic": message.topic ?? options.topic
        ]
        
        if let collapseId = message.collapseIdentifier {
            headers["apns-collapse-id"] = collapseId
        }
        
        if let threadId = message.threadIdentifier {
            headers["thread-id"] = threadId
        }
        
        return headers
        
    }
    
    fileprivate class WriteStorage {
        var data = Data()
    }
}

extension VaporAPNS {
    fileprivate func hostURL(_ development: Bool) -> String {
        if development {
            return "https://api.development.push.apple.com" //   "
        } else {
            return "https://api.push.apple.com" //   /3/device/"
        }
    }
}

struct KeyID: Header {
    static let name = "kid"
    var node: Node
    init(_ keyID: String) {
        node = Node(keyID)
    }
}
