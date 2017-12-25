import Dispatch
import Foundation
import SwiftString
import JSON
import CCurl
import JSON
import JWT
import Console


open class VaporAPNS {
    
    fileprivate var options: Options
    private var lastGeneratedToken: (date: Date, token: String)?
    
    fileprivate var curlHandle: UnsafeMutableRawPointer!
    
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
        
        self.curlHandle = curl_multi_init()
        curlHelperSetMultiOpt(curlHandle, CURLMOPT_PIPELINING, CURLPIPE_MULTIPLEX)
    }
    
    deinit {
        curl_multi_cleanup(self.curlHandle)
    }
    
    // MARK: CURL Config
    
    private func configureCurlHandle(for message: ApplePushMessage,
                                     to deviceToken: String,
                                     completionHandler: @escaping (Result) -> Void) -> Connection? {
        guard let handle = curl_easy_init() else { return nil }
        
        curlHelperSetOptBool(handle, CURLOPT_VERBOSE, options.debugLogging ? CURL_TRUE : CURL_FALSE)
        
        if self.options.usesCertificateAuthentication {
            curlHelperSetOptString(handle, CURLOPT_SSLCERT, options.certPath)
            curlHelperSetOptString(handle, CURLOPT_SSLCERTTYPE, "PEM")
            curlHelperSetOptString(handle, CURLOPT_SSLKEY, options.keyPath)
            curlHelperSetOptString(handle, CURLOPT_SSLKEYTYPE, "PEM")
        }
        
        curlHelperSetOptInt(handle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0)
        
        let url = ("\(self.hostURL(message.sandbox))/3/device/\(deviceToken)")
        curlHelperSetOptString(handle, CURLOPT_URL, url)
        
        // force set port to 443
        curlHelperSetOptInt(handle, CURLOPT_PORT, options.port.rawValue)
        
        // Follow location
        curlHelperSetOptBool(handle, CURLOPT_FOLLOWLOCATION, CURL_TRUE)
        
        // set POST request
        curlHelperSetOptBool(handle, CURLOPT_POST, CURL_TRUE)
        
        // Pipeline
        curlHelperSetOptInt(handle, CURLOPT_PIPEWAIT, 1)
        
        // setup payload
        
        // Use CURLOPT_COPYPOSTFIELDS so Swift can release str and let CURL take
        // care of the rest. This implies we need to set CURLOPT_POSTFIELDSIZE
        // first
        let serialized = try! message.payload.makeJSON().serialize(prettyPrint: false)
        let str = String(bytes: serialized)
        curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, str.utf8.count)
        curlHelperSetOptString(handle, CURLOPT_COPYPOSTFIELDS, str.cString(using: .utf8))
        
        // Tell CURL to add headers
        curlHelperSetOptBool(handle, CURLOPT_HEADER, CURL_TRUE)
        
        //Headers
        let headers = self.requestHeaders(for: message)
        var curlHeaders: UnsafeMutablePointer<curl_slist>?
        if !options.usesCertificateAuthentication {
            let token: String
            if let recentToken = lastGeneratedToken, abs(recentToken.date.timeIntervalSinceNow) < 59 * 60 {
                token = recentToken.token
            } else {
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
                
                token = tokenString.replacingOccurrences(of: " ", with: "")
                lastGeneratedToken = (date: Date(), token: token)
            }
            
            curlHeaders = curl_slist_append(curlHeaders, "Authorization: bearer \(token)")
        }
        curlHeaders = curl_slist_append(curlHeaders, "User-Agent: VaporAPNS")
        for header in headers {
            curlHeaders = curl_slist_append(curlHeaders, "\(header.key): \(header.value)")
        }
        curlHeaders = curl_slist_append(curlHeaders, "Accept: application/json")
        curlHeaders = curl_slist_append(curlHeaders, "Content-Type: application/json");
        curlHelperSetOptList(handle, CURLOPT_HTTPHEADER, curlHeaders)
        
        return Connection(handle: handle,
                          message: message,
                          token: deviceToken,
                          headers: curlHeaders,
                          completionHandler: completionHandler)
    }
    
    private func requestHeaders(for message: ApplePushMessage) -> [String: String] {
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
    
    // MARK: Connections
    
    private let connectionQueue: DispatchQueue = DispatchQueue(label: "VaporAPNS.connection-managment")
    
    private class Connection: Equatable, Hashable {
        private(set) var data: Data = Data()
        let handle: UnsafeMutableRawPointer
        let headers: UnsafeMutablePointer<curl_slist>?
        let messageId: String
        let token: String
        let completionHandler: (Result) -> Void
        
        fileprivate func append(bytes: [UInt8]) {
            data.append(contentsOf: bytes)
        }
        
        init(handle: UnsafeMutableRawPointer, message: ApplePushMessage, token: String, headers: UnsafeMutablePointer<curl_slist>?, completionHandler: @escaping (Result) -> Void) {
            self.handle = handle
            self.messageId = message.messageId
            self.token = token
            self.completionHandler = completionHandler
            self.headers = headers
        }
        
        deinit {
            // if the connection get's dealloced we can clenaup the
            // curl structures as well
            curl_slist_free_all(headers)
            curl_easy_cleanup(handle)
        }
        
        var hashValue: Int { return messageId.hashValue }
        
        static func == (lhs: Connection, rhs: Connection) -> Bool {
            return lhs.messageId == rhs.messageId && lhs.token == rhs.token
        }
    }
    
    private var connections: Set<Connection> = Set()
    
    private func complete(connection: Connection) {
        connectionQueue.async {
            guard self.connections.contains(connection) else { return }
            self.connections.remove(connection)
            self.performQueue.async {
                curl_multi_remove_handle(self.curlHandle, connection.handle)
                self.handleCompleted(connection: connection)
            }
        }
    }
    
    private func handleCompleted(connection: Connection) {
        // Create string from Data
        let str = String.init(data: connection.data, encoding: .utf8)!
        
        // Split into two pieces by '\r\n\r\n' as the response has two newlines before the returned data. This causes us to have two pieces, the headers/crap and the server returned data
        let splittedString = str.components(separatedBy: "\r\n\r\n")
        let result: Result!
        
        // Ditch the first part and only get the useful data part
        let dataString: String?
        if splittedString.count > 1 {
            dataString = splittedString[1]
        } else {
            dataString = nil
        }
        
        if let responseData = dataString,
            responseData != "",
            let data = responseData.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let responseJSON = json as? [String: Any] {
            
            // Get JSON from loaded data string
            if let reason = responseJSON["reason"] as? String {
                result = Result.error(apnsId: connection.messageId,
                                      deviceToken: connection.token,
                                      error: APNSError.init(errorReason: reason))
            } else {
                result = Result.success(apnsId: connection.messageId,
                                        deviceToken: connection.token,
                                        serviceStatus: .success)
            }
        } else {
            result = Result.success(apnsId: connection.messageId,
                                    deviceToken: connection.token,
                                    serviceStatus: .success)
        }
        
        connection.completionHandler(result)
    }
    
    // MARK: Running cURL Multi
    
    private let performQueue: DispatchQueue = DispatchQueue(label: "VaporAPNS.curl_multi_perform")
    
    private var runningConnectionsCount: Int32 = 0
    
    private var repeats = 0
    
    /// Core cURL-multi Loop is done here
    private func performActiveConnections() {
        var code: CURLMcode = CURLM_CALL_MULTI_PERFORM
        
        var numfds: Int32 = 0
        
        code = curl_multi_perform(self.curlHandle, &self.runningConnectionsCount)
        if code == CURLM_OK {
            code = curl_multi_wait(self.curlHandle, nil, 0, 1000, &numfds);
        }
        if code != CURLM_OK {
            print("curl_multi_wait failed with error code \(code): \(String(cString: curl_multi_strerror(code)))")
            return
        }
        
        if numfds != 0 {
            self.repeats += 1
        } else {
            self.repeats = 0
        }
        
        var numMessages: Int32 = 0
        var curlMessage: UnsafeMutablePointer<CURLMsg>?
        
        repeat {
            curlMessage = curl_multi_info_read(self.curlHandle, &numMessages)
            if let message = curlMessage {
                let handle = message.pointee.easy_handle
                let msg = message.pointee.msg
                
                if msg == CURLMSG_DONE {
                    self.connectionQueue.async {
                        
                        guard let connection = self.connections.first(where: { $0.handle == handle }) else {
                            self.performQueue.async {
                                print("Warning: Removing handle not in connection list")
                                curl_multi_remove_handle(self.curlHandle, handle)
                            }
                            return
                        }
                        
                        self.complete(connection: connection)
                    }
                    
                    
                } else {
                    print("Connection failiure: \(msg) \(String(cString: curl_easy_strerror(message.pointee.data.result)))")
                }
            }
            
        } while numMessages > 0
        
        if self.runningConnectionsCount > 0 {
            performQueue.async {
                if self.repeats > 1 {
                    self.performQueue.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        self.performActiveConnections()
                    }
                } else {
                    self.performActiveConnections()
                }
            }
        }
        
    }
    
    
    // MARK: API
    
    open func send(_ message: ApplePushMessage, to deviceToken: String, completionHandler: @escaping (Result) -> Void) {
        guard let connection = configureCurlHandle(for: message, to: deviceToken, completionHandler: completionHandler) else {
            completionHandler(Result.networkError(error: SimpleError.string(message: "Could not configure cURL")))
            return
        }
        
        connectionQueue.async {
            self.connections.insert(connection)
            let ptr = Unmanaged<Connection>.passUnretained(connection).toOpaque()
            let _ = curlHelperSetOptWriteFunc(connection.handle, ptr) { (ptr, size, nMemb, privateData) -> Int in
                let realsize = size * nMemb
                
                let pointee = Unmanaged<Connection>.fromOpaque(privateData!).takeUnretainedValue()
                var bytes: [UInt8] = [UInt8](repeating: 0, count: realsize)
                memcpy(&bytes, ptr!, realsize)
                
                pointee.append(bytes: bytes)
                return realsize
            }
            
            self.performQueue.async {
                // curlHandle should only be touched on performQueue
                curl_multi_add_handle(self.curlHandle, connection.handle)
                self.performActiveConnections()
            }
        }
    }
    
    open func send(_ message: ApplePushMessage, to deviceTokens: [String], perDeviceResultHandler: @escaping ((_ result: Result) -> Void)) {
        for deviceToken in deviceTokens {
            self.send(message, to: deviceToken, completionHandler: perDeviceResultHandler)
        }
    }
    
    // MARK: Helpers
    
    private func toNullTerminatedUtf8String(_ str: [UTF8.CodeUnit]) -> Data? {
        return str.withUnsafeBufferPointer() { buffer -> Data? in
            return buffer.baseAddress != nil ? Data(bytes: buffer.baseAddress!, count: buffer.count) : nil
        }
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

