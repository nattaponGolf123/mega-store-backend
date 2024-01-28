//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/1/2567 BE.
//

import Foundation
import Vapor
import JWT

struct UserJWTPayload: JWTPayload {
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case id = "id"
        case username = "username"
        case fullname = "fullname"
    }
    
    let subject: SubjectClaim
    let expiration: ExpirationClaim
    
    let userID: Int
    let username: String
    let userFullname: String
    
    init(subject: SubjectClaim, 
         expiration: ExpirationClaim,
         userID: Int,
         username: String,
         userFullname: String) {
        self.subject = subject
        self.expiration = expiration
        self.userID = userID
        self.username = username
        self.userFullname = userFullname
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subject = try container.decode(SubjectClaim.self,
                                       forKey: .subject)
        expiration = try container.decode(ExpirationClaim.self,
                                          forKey: .expiration)
        userID = try container.decode(Int.self,
                                      forKey: .id)
        username = try container.decode(String.self,
                                        forKey: .username)
        userFullname = (try? container.decode(String?.self,
                                            forKey: .fullname)) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subject,
                             forKey: .subject)
        try container.encode(expiration,
                             forKey: .expiration)
        try container.encode(userID,
                             forKey: .id)
        try container.encode(username,
                             forKey: .username)
        try container.encode(userFullname,
                             forKey: .fullname)
    }
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

extension UserJWTPayload: Authenticatable { }

