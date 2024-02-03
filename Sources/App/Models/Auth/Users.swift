//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor

struct Users: Codable {
    var lists: [User]
    
    init(lists: [User]) {
        self.lists = lists
    }

    init(from decoder: Decoder) throws {
        var lists = [User]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let product = try container.decode(User.self)
            lists.append(product)
        }
        self.lists = lists
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for product in lists {
            try container.encode(product)
        }
    }
    
    func find(id: UUID) -> User? {
        return lists.first { $0.id == id }
    }
        
    func find(username: String) -> User? {
        return lists.first { $0.username == username }
    }
    
    func find(token: String) -> User? {
        return lists.first { $0.token == token }
    }
    
    mutating func replace(_ user: User) {
        guard
            let index = lists.firstIndex(where: { $0.id == user.id })
        else { return }
        
        lists[index] = user
    }
}

//extension Users: AsyncResponseEncodable {
//    func encodeResponse(for request: Request) async throws -> Response {
//        let response = Response()
//        try response.content.encode(self,
//                                    as: .json)
//        return response
//    }
//}

extension Users: Content {}

extension Users {
    struct Stub {
        static var allUsers: Users {
            return Users(lists: [
                User.Stub.user1
            ])
        }
    }
}
