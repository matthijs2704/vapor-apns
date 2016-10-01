//
//  JSON+String.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/10/2016.
//
//

import Foundation
import JSON

extension JSON {
    func toString() throws -> String {
        let bytes = try self.serialize(prettyPrint: false)
        let data = Data.init(bytes: bytes)
        let plString = String(data: data, encoding: .utf8)
        return plString!
    }
}
