//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor

struct User: Codable {
    let id: Int
    let username: String
    let password: String
    let fullname: String
        
    var token: String?
    var tokenExpried: Date?
    
    init(id: Int,
         username: String,
         password: String,
         fullname: String,
         token: String? = nil) {
        self.id = id
        self.username = username
        self.password = password
        self.fullname = fullname
        
        if let token {
            self.token = token
            self.tokenExpried = nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self,
                                  forKey: .id)
        username = try container.decode(String.self,
                                        forKey: .username)
        password = try container.decode(String.self,
                                        forKey: .password)
        fullname = try container.decode(String.self,
                                        forKey: .fullname)
        
        token = try? container.decodeIfPresent(String.self,
                                              forKey: .token)
        tokenExpried = try? container.decodeIfPresent(Date.self,
                                                     forKey: .expried)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,
                             forKey: .id)
        try container.encode(username,
                             forKey: .username)
        try container.encode(password,
                             forKey: .password)
        try container.encode(fullname,
                             forKey: .fullname)        
        try container.encode(token,
                             forKey: .token)
        try container.encode(tokenExpried,
                             forKey: .expried)
    }
    
    mutating func generateToken() {
        let _15Day: TimeInterval = 60 * 60 * 24 * 15
        
        token = UUID().uuidString
        tokenExpried = Date().addingTimeInterval(_15Day)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case password = "password"
        case fullname = "fullname"
        case token = "token"
        case expried = "expried"
    }
}

extension User: Authenticatable {
    
}

extension User: AsyncResponseEncodable {
    func encodeResponse(for request: Request) async throws -> Response {
        let response = Response()
        try response.content.encode(self,
                                    as: .json)
        return response
    }
}

extension User {
    struct Stub {
        static var user1: User {
            return User(id: 1,
                        username: "admin",
                        password: "1234",
                        fullname: "Admin",
                        token: "admin")
        }
    }
}
