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

enum UserRole: String, Codable {
    case manager
    case owner
    case staff    
}

final class User: Model, Content {
    static let schema = "Users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String

    @Field(key: "personal_information")
    var personalInformation: PersonalInformation
        
    @Enum(key: "type")
    var type: UserType
    
    @OptionalField(key: "token")
    var token: String?
    
    @OptionalField(key: "expried")
    var tokenExpried: Date?

    @Field(key: "last_login_at")
    var lastLoginAt: Date?

    @Field(key: "active")
    var active: Bool
    
    @Timestamp(key: "created_at", 
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", 
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", 
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         username: String,
         passwordHash: String,
         personalInformation: PersonalInformation = .init(),
         userType: UserType = .user,
         token: String? = nil,
         tokenExpried: Date? = nil,
         lastLoginAt: Date? = nil,
         active: Bool = true,
         createAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? UUID()
        self.username = username
        self.passwordHash = passwordHash
        self.personalInformation = personalInformation
        self.type = userType
        self.active = active
        self.token = token
        self.tokenExpried = tokenExpried
        self.lastLoginAt = lastLoginAt        
        self.createdAt = createAt
        self.updatedAt = updatedAt
    }
    
    func newUser(username: String,
                 password: String,
                 fullname: String) -> User {
        return User(id: .init(),
                    username: username,
                    passwordHash: password,
                    personalInformation: PersonalInformation(fullname: fullname),
                    userType: .user)
    }
    
    func setToken(_ token: String,
                  expried: Date,
                  lastLoginAt: Date = .init()) {
        self.token = token
        self.tokenExpried = expried
        self.lastLoginAt = lastLoginAt
    }
    
    func clearToken() {
        self.token = nil
        self.tokenExpried = nil
    }
   
}

extension User {
    struct PersonalInformation: Content {
        var fullname: String
        var email: String
        var phone: String
        var address: String
        var signSignature: String?

        init(fullname: String = "",
             email: String = "",
             phone: String = "",
             address: String = "",
             signSignature: String? = nil) {
            self.fullname = fullname
            self.email = email
            self.phone = phone
            self.address = address
            self.signSignature = signSignature
        }

        enum CodingKeys: String, CodingKey {
            case fullname
            case email
            case phone
            case address
            case signSignature = "sign_signature"
        }
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
                        personalInformation: User.PersonalInformation(fullname: "User 1"))
        }
        
        static var admin: User {
            return User(username: "admin",
                        passwordHash: "$2b$12$Iys1MXvDx5JvfOFgHAnCAOG9/h51Es9chnc3RpMjbZDjox.rgN9pa",
                        personalInformation: User.PersonalInformation(fullname: "Admin"),
                        userType: .admin)
        }
    }
}
    
/*
JSON Response
{
"username": "theresa59",
"password": "^7Wqb49P*!",
"token": "",
"created_at": "1995-03-13T16:21:25",
"updated_at": "1983-02-27T12:25:49",
"delete_at": "1982-10-11T12:02:34",
"personal_information": {
    "fullname": "Theresa",
    "email": "",
    "phone": "",
    "address": "",
    "sign_signature": "https://www.example.com/signature/theresa59.png"
},
"type": "user",
"last_login_at": "1995-03-13T16:21:25",
"active": true,
}

*/
