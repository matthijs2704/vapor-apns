//
//  JSON+String.swift
//  VaporAPNS
//
//  Created by Jimmy Arts on 19/05/2017.
//
//

import Foundation
import JSON

extension JSON {
    func toString() throws -> String {
        let bytes = try self.serialize(prettyPrint: false)
        let data = Data(bytes: bytes)
        let plString = String(data: data, encoding: .utf8)
        return plString!
    }
}
