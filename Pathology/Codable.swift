//
//  Codable.swift
//  Pathology iOS
//
//  Created by Firdavs Khaydarov on 24/02/20.
//  Copyright © 2020 keighl. All rights reserved.
//

import Foundation

public extension Encodable {
    func toJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

public extension Decodable {
    static func fromJSON(_ json: String) throws -> Self {
        let data = json.data(using: .utf8) ?? Data()
        
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func fromJSON(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
