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
    
    private(set) var repository: UserAuthenticationRepositoryProtocol
    private(set) var validator: AuthControllerValidatorProtocol
    
    init(repository: UserAuthenticationRepositoryProtocol = UserAuthenticationRepository(),
         validator: AuthControllerValidatorProtocol = AuthControllerValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
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
        let userPayload = try validator.validatePayload(req)
        try await repository.verifyExistToken(id: userPayload.userID,
                                              on: req.db)
        return .ok
    }
    
//    func verifyToken(req: Request) async throws -> HTTPStatus {
//        do {
//   
//            // check user.tokenExpried is not nil
//            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//            guard
//                let foundUser = try await User.find(userPayload.userID,
//                                                    on: req.db),
//                foundUser.tokenExpried != nil
//            else {
//                throw Abort(.notFound)
//            }
//            
//            return .ok
//        } catch {
//            //return .unauthorized
//            throw AuthError.invalidToken
//        }
//    }
    
    // POST /user
    func signinJWT(req: Request) async throws -> [String: String] {
        // try to decode param by Auth
        let signIn = try validator.validateSignIn(req)
        let foundUser = try await repository.findUser(username: signIn.username,
                                                      on: req.db)
        let verified = try validator.validatePassword(req,
                                           pwd: signIn.password,
                                           hashPwd: foundUser.passwordHash)
        guard
            verified
        else { throw AuthError.invalidUsernameOrPassword }
        
        let updatedUser = try await repository.generateToken(req: req,
                                                             user: foundUser,
                                                             on: req.db)
        return ["token": updatedUser.token ?? ""]
    }
    
//    func signinJWT(req: Request) async throws -> [String: String] {
//        // try to decode param by Auth
//        let content = try req.content.decode(SignIn.self)
//        
//        // validate
//        try SignIn.validate(content: req)
//        
//        // load from database
//        do {
//            guard 
//                let foundUser = try await User.query(on: req.db)
//                    .filter(\.$username == content.username)
//                    .first()
//            else {
//                //throw Abort(.notFound)
//                throw AuthError.userNotFound
//            }
//
//            // debug
//            //let pwdDigest = try req.password.hash(content.password)
//            
//            let pwdVerify = try req.password.verify(content.password,
//                                                    created: foundUser.passwordHash)
//            guard
//                pwdVerify
//            else {
//                //throw Abort(.notFound)
//                throw AuthError.invalidUsernameOrPassword
//            }
//            
//            
//            let payload = UserJWTPayload(subject: "mega-store-user",
//                                         expiration: .init(value: .distantFuture),
//                                         userID: foundUser.id!,
//                                         username: foundUser.username,
//                                         userFullname: foundUser.fullname,
//                                         isAdmin: foundUser.type == UserType.admin)
//            
//            
//            let token = try req.jwt.sign(payload)
//            
//            foundUser.setToken(token,
//                               expried: payload.expiration.value)
//            
//            try await foundUser.save(on: req.db)
//            
//            return ["token": token]
//        } catch {
//            throw AuthError.userNotFound
//        }
//    }
    
    //POST /user/logout
    func logout(req: Request) async throws -> HTTPStatus {
        let userPayload = try validator.validatePayload(req)
        _ = try await repository.clearToken(id: userPayload.userID,
                                            on: req.db)
        return .ok
    }
    
//    func logout(req: Request) async throws -> HTTPStatus {
//        do {
//            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//            guard
//                let foundUser = try await User.find(userPayload.userID,
//                                                    on: req.db)
//            else {
//                //throw Abort(.notFound)
//                throw AuthError.userNotFound
//            }
//            
//            foundUser.clearToken()
//            try await foundUser.save(on: req.db)
//            
//            return .ok
//        } catch {
//            //return .unauthorized
//            throw AuthError.userNotFound
//        }
//    }
}


