//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        users.group("me") { usersMe in
            usersMe.get(use: me)
        }
        
    }
    
    // POST /users
    func create(req: Request) async throws -> User {
        
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        
        // allow only admin
        guard
            userPayload.isAdmin
        else { throw Abort(.unauthorized) }
        
        let content = try req.content.decode(CreateUser.self)

        // validate
        try CreateUser.validate(content: req)
        
        
        let hashPwd = try getPwd(env: req.application.environment,
                             pwd: content.password)
        
        let newUser = User(username: content.username,
                           passwordHash: hashPwd,
                           fullname: content.fullname,
                           userType: .user)
        try await newUser.save(on: req.db).get()
        
        return newUser
    }
    
    // GET /users/me
    func me(req: Request) async throws -> User {
        do {
            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
            guard
                let foundUser = try await User.find(userPayload.userID,
                                                    on: req.db),
                foundUser.tokenExpried != nil
            else {
                throw Abort(.notFound)
            }
            
            return foundUser
        } catch {
            throw Abort(.notFound)
        }
    }
    
}

private extension UserController {
    func getPwd(env: Environment,
                pwd: String) throws -> String {
        switch env {
            // bcrypt
        case .production,
             .development:
            return try Bcrypt.hash(pwd)
            
        //plaintext on testing
        default:
            return pwd
        }
    }
}
