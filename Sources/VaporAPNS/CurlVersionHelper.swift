//
//  CurlVersionHelper.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/01/2017.
//
//

import Foundation
import CCurl
import Console

open class CurlVersionHelper {
    public enum Result {
        case ok
        case old
        case noHTTP2
        case unknown
    }
    
    public func checkVersion(autoInstall: Bool = false) {
        let result = checkVersionNum()
        if result == .old {
            let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)
            
            var response = ""
            
            if !autoInstall {
                console.output("Your current version of curl is out of date!\nVaporAPNS will not work with this version of curl.", style: .error)
                console.output("You can update curl yourself or we can try to update curl and it's nescessary dependencies.", style: .info)
                response = console.ask("Continue installing curl? [y/n]", style: .info)
            }
            
            if response == "y" || autoInstall {
                let curlupdater = CurlUpdater()
                curlupdater.updateCurl()
            }else {
                exit(1)
            }
        }else if result == .noHTTP2 {
            let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)
            
            var response = ""
            
            if !autoInstall {
                console.output("Your current version of curl lacks HTTP2!\nVaporAPNS will not work with this version of curl.", style: .error)
                console.output("You can either let VaporAPNS rebuild and install curl for you or you can rebuild curl with HTTP2 support yourself.", style: .info)
                response = console.ask("Continue rebuilding curl? [y/n]", style: .info)
            }
            
            if response == "y" || autoInstall {
                let curlupdater = CurlUpdater()
                curlupdater.updateCurl()
            }else {
                exit(1)
            }
        }
    }
    
    private func checkVersionNum() -> Result {
        let version = curl_version_info(CURLVERSION_FOURTH)
        let verBytes = version?.pointee.version
        let versionString = String.init(cString: verBytes!)
//        return .old
        
        guard checkVersionNumber(versionString, "7.51.0") >= 0 else {
            return .old
        }
        
        let features = version?.pointee.features
        
        if ((features! & CURL_VERSION_HTTP2) == CURL_VERSION_HTTP2) {
            return .ok
        }else {
            return .noHTTP2
        }
    }
    
    private func checkVersionNumber(_ strVersionA: String, _ strVersionB: String) -> Int{
        var arrVersionA = strVersionA.split(".").map({ Int($0) })
        guard arrVersionA.count == 3 else {
            fatalError("Wrong curl version scheme! \(strVersionA)")
        }
        
        var arrVersionB = strVersionB.split(".").map({ Int($0) })
        guard arrVersionB.count == 3 else {
            fatalError("Wrong curl version scheme! \(strVersionB)")
        }
        
        let intVersionA = (100000000 * arrVersionA[0]!) + (1000000 * arrVersionA[1]!) + (10000 * arrVersionA[2]!)
        let intVersionB = (100000000 * arrVersionB[0]!) + (1000000 * arrVersionB[1]!) + (10000 * arrVersionB[2]!)
//        let intVersionA = 0
//        let intVersionB = 0
        
        if (intVersionA > intVersionB) {
            return 1
        }else if(intVersionA < intVersionB){
            return -1
        }else{
            return 0
        }
    }
    
    
}
