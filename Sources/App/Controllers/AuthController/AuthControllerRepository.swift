//
//  File.swift
//
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol UserAuthenticationRepositoryProtocol {
    func findUser(userID: UUID,
                  on db: Database) async throws -> User
    func findUser(username: String,
                  on db: Database) async throws -> User
    func clearToken(id: UUID,
                    on db: Database) async throws -> User
    func generateToken(req: Request,
                       user: User,
                       on db: Database) async throws -> User
    func verifyExistToken(id: UUID,
                          on db: Database) async throws
    
}

class UserAuthenticationRepository: UserAuthenticationRepositoryProtocol {
    
    func findUser(userID: UUID,
                  on db: Database) async throws -> User {
        guard
            let foundUser = try await User.find(userID,
                                                on: db)
        else {
            throw AuthError.userNotFound
        }
        
        return foundUser
    }
    
    func findUser(username: String,
                  on db: Database) async throws -> User {
        guard
            let foundUser = try await User.query(on: db)
                .filter(\.$username == username)
                .first()
        else {
            throw AuthError.userNotFound
        }
        
        return foundUser
    }
    
    func clearToken(id: UUID,
                    on db: Database) async throws -> User {
        guard
            let user = try await User.find(id,
                                           on: db)
        else { throw AuthError.userNotFound }
        
        user.clearToken()
        try await user.save(on: db)
        
        return user
    }
    
    func generateToken(req: Request,
                       user: User,
                       on db: Database) async throws -> User {
        let payload = UserJWTPayload(user: user)
        
        let token = try req.jwt.sign(payload)
        
        user.setToken(token,
                      expried: payload.expiration.value)
        
        try await user.save(on: db)
        
        return user
    }
    
    func verifyExistToken(id: UUID,
                          on db: Database) async throws {
        let foundUser = try await findUser(userID: id,
                                           on: db)
        guard
            let _ = foundUser.token,
            let _ = foundUser.tokenExpried
        else { throw AuthError.invalidToken }
        
    }

}
