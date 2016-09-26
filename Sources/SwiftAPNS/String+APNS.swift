//
//  String+APNS.swift
//  VaporAPNS
//
//  Created by Nathan Flurry on 9/26/16.
//
//

import Foundation

extension String {
    /// Converts the string (which is a path for the auth key) to a token string
    func tokenString() throws -> String {
        guard let authKeyUrl = URL(string: self) else {
            throw TokenError.invalidAuthKey
        }
        
        let fileString = try String(contentsOf: authKeyUrl, encoding: .utf8)
        
        guard
            let tokenString =
            fileString.collapseWhitespace().between(
                "-----BEGIN PRIVATE KEY-----",
                "-----END PRIVATE KEY-----"
            )?.trimmed()
        else {
            throw TokenError.invalidTokenString
        }
        
        guard tokenString.characters.count == 200 else {
            throw TokenError.wrongTokenLength
        }
        
        return tokenString
    }
}
