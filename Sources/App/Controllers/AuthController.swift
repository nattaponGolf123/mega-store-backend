//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor
import JWT
import Fluent

class AuthController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post(use: signinJWT)
        
        auth.group("token_verify") { authVerify in
            authVerify.post(use: verifyToken)
        }
        
        auth.group("logout") { authLogout in
            authLogout.post(use: logout)
        }
    }
    
    // POST /user/token_verify
    func verifyToken(req: Request) async throws -> HTTPStatus {
        do {
            _ = try req.jwt.verify(as: UserJWTPayload.self)
            
            // check user.tokenExpried is not nil
//            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//            guard
//                let foundUser = try await User.find(userPayload.userID,
//                                                    on: req.db),
//                foundUser.tokenExpried != nil
//            else {
//                throw Abort(.notFound)
//            }
            
            return .ok
        } catch {
            return .unauthorized
        }
    }
    
    // POST /user
    func signinJWT(req: Request) async throws -> [String: String] {
        // try to decode param by Auth
        let content = try req.content.decode(SignIn.self)
        
        // validate
        try SignIn.validate(content: req)
        
        // load from database
        do {
            guard 
                let foundUser = try await User.query(on: req.db)
                    .filter(\.$username == content.username)
                    .first()
            else {
                throw Abort(.notFound)
            }

            // debug
            //let pwdDigest = try req.password.hash(content.password)
            
            let pwdVerify = try req.password.verify(content.password,
                                                    created: foundUser.passwordHash)
            guard
                pwdVerify
            else { throw Abort(.notFound) }
            
            
            let payload = UserJWTPayload(subject: "mega-store-user",
                                         expiration: .init(value: .distantFuture),
                                         userID: foundUser.id!,
                                         username: foundUser.username,
                                         userFullname: foundUser.fullname,
                                         isAdmin: foundUser.type == UserType.admin)
            
            
            let token = try req.jwt.sign(payload)
            
            foundUser.setToken(token,
                               expried: payload.expiration.value)
            
            try await foundUser.save(on: req.db)
            
            return ["token": token]
        } catch {
            throw Abort(.notFound)
        }
    }
    
    //POST /user/logout
    func logout(req: Request) async throws -> HTTPStatus {
        do {
            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
            guard
                let foundUser = try await User.find(userPayload.userID,
                                                    on: req.db)
            else {
                throw Abort(.notFound)
            }
            
            foundUser.clearToken()
            try await foundUser.save(on: req.db)
            
            return .ok
        } catch {
            return .unauthorized
        }
    }
}

extension AuthController {
    
    struct SignIn: Content, Validatable {
        let username: String
        let password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String.self,
                            is: .count(3...))
            validations.add("password", as: String.self,
                            is: .count(3...))
        }
    }
}


