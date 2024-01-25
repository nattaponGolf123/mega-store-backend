//
//  File.swift
//  
//
//  Created by IntrodexMac on 23/1/2567 BE.
//

import Foundation
import Vapor

struct ObjectResponse: Encodable {
    
    let result: Encodable
    
    init(result: Encodable) {
        self.result = result
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(result, forKey: .result)
    }
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}

//extension ObjectResponse: ResponseEncodable {
//    func encode(for req: Request) throws -> EventLoopFuture<Response> {
//        let res = req.response()
//        try res.content.encode(self, as: .json)
//        return res.encodeResponse(for: req)
//    }
//}


/*
 will return
 {
    "result" : {
 
    }
 }
 */
