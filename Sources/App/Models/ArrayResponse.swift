//
//  File.swift
//  
//
//  Created by IntrodexMac on 23/1/2567 BE.
//

import Foundation

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<E: Encodable>(_ encodable: E) {
        _encode = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

struct ArrayResponse: Encodable {
    let results: [AnyEncodable]

    init(lists: [Encodable]) {
        self.results = lists.map { AnyEncodable($0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(results, forKey: .results)
    }

    enum CodingKeys: String, CodingKey {
        case results
    }
}


/*
 will return
 {
    "results" : [{
 
    }]
 }
 */
