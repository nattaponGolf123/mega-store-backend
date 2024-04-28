//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor
import Fluent

enum UserType: String, Codable {
    case admin
    case user
}

final class User: Model, Content {
    static let schema = "Users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "fullname")
    var fullname: String
    
    @Enum(key: "type")
    var type: UserType
    
    @OptionalField(key: "token")
    var token: String?
    
    @OptionalField(key: "expried")
    var tokenExpried: Date?
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete, format: .iso8601)
    var deletedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         username: String,
         passwordHash: String,
         fullname: String,
         userType: UserType = .user,
         token: String? = nil,
         tokenExpried: Date? = nil) {
        self.id = id ?? UUID()
        self.username = username
        self.passwordHash = passwordHash
        self.fullname = fullname
        self.type = userType
        self.token = token
        self.tokenExpried = tokenExpried
    }
    
//    init(username: String,
//         passwordHash: String,
//         fullname: String) {
//        self.id = UUID()
//        self.username = username
//        self.passwordHash = passwordHash
//        self.fullname = fullname
//        self.type = userType
//        self.token =
//        self.tokenExpried = tokenExpried
//    }
    
    func newUser(username: String,
                 password: String,
                 fullname: String) -> User {
        return User(id: .init(),
                    username: username,
                    passwordHash: password,
                    fullname: fullname,
                    userType: .user)
    }
    
    func setToken(_ token: String,
                  expried: Date) {
        self.token = token
        self.tokenExpried = expried
    }
    
    func clearToken() {
        self.token = nil
        self.tokenExpried = nil
    }
}

extension User: Authenticatable {}

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
            return User(username: "user1",
                        passwordHash: "user1",
                        fullname: "User 1")
        }
        
        static var admin: User {
            return User(username: "admin",
                        passwordHash: "$2b$12$Iys1MXvDx5JvfOFgHAnCAOG9/h51Es9chnc3RpMjbZDjox.rgN9pa",
                        fullname: "Admin",
                        userType: .admin)
        }
    }
}
    
