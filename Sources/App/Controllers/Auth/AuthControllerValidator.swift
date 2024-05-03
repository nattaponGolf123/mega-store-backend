//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

protocol AuthControllerValidatorProtocol {
    func validatePayload(_ content: Request) throws -> UserJWTPayload
    func validateSignIn(_ content: Request) throws -> AuthController.SignIn
    func validatePassword(_ content: Request,
                          pwd: String,
                          hashPwd: String) throws -> Bool
    
    func validateTokenNotExpried(_ user: User) -> Bool
    
    //func validateToken(_ content: Request) throws -> Bool
//    func validatePassword(_ content: Request,
//                          pwd: String) throws -> Bool
}

class AuthControllerValidator: AuthControllerValidatorProtocol {
    
    func validatePayload(_ content: Request) throws -> UserJWTPayload {
        do {
            return try content.jwt.verify(as: UserJWTPayload.self)
        } catch {
            throw AuthError.invalidToken
        }
    }
    
    func validateSignIn(_ content: Request) throws -> AuthController.SignIn {
        do {
            let signIn = try content.content.decode(AuthController.SignIn.self)
            try AuthController.SignIn.validate(content: content)
            return signIn
        } catch {
            throw AuthError.invalidUsernameOrPassword
        }
    }
    
    func validateTokenNotExpried(_ user: User) -> Bool {
        guard
            let tokenExpried = user.tokenExpried
        else { return false }
        
        return tokenExpried <= Date()
    }
    
    func validatePassword(_ content: Request,
                          pwd: String,
                          hashPwd: String) throws -> Bool {
        return try content.password.verify(pwd,
                                           created: hashPwd)
    }
    
//    func validateToken(_ payload: UserJWTPayload) throws -> Bool {
//        let userPayload = try content.jwt.verify(as: UserJWTPayload.self)
//        guard
//            let foundUser = try await User.find(userPayload.userID,
//                                                on: content.db),
//            foundUser.tokenExpried != nil
//        else {
//            throw AuthError.invalidToken
//        }
//        
//        return true
//    }
    
//    func validatePassword(_ content: Request,
//                          pwd: String) throws -> Bool {
//        let userPayload = try content.jwt.verify(as: UserJWTPayload.self)
//        guard
//            let foundUser = try await User.find(userPayload.userID,
//                                                on: content.db),
//            let password = foundUser.password
//        else {
//            throw AuthError.userNotFound
//        }
//        
//        return try Bcrypt.verify(pwd, created: password)
//    }
}

/*
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
 //            _ = try req.jwt.verify(as: UserJWTPayload.self)
             
             // check user.tokenExpried is not nil
             let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
             guard
                 let foundUser = try await User.find(userPayload.userID,
                                                     on: req.db),
                 foundUser.tokenExpried != nil
             else {
                 throw Abort(.notFound)
             }
             
             return .ok
         } catch {
             //return .unauthorized
             throw AuthError.invalidToken
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
                 //throw Abort(.notFound)
                 throw AuthError.userNotFound
             }

             // debug
             //let pwdDigest = try req.password.hash(content.password)
             
             let pwdVerify = try req.password.verify(content.password,
                                                     created: foundUser.passwordHash)
             guard
                 pwdVerify
             else {
                 //throw Abort(.notFound)
                 throw AuthError.invalidUsernameOrPassword
             }
             
             
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
             //throw Abort(.notFound)
             throw AuthError.userNotFound
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
                 //throw Abort(.notFound)
                 throw AuthError.userNotFound
             }
             
             foundUser.clearToken()
             try await foundUser.save(on: req.db)
             
             return .ok
         } catch {
             //return .unauthorized
             throw AuthError.userNotFound
         }
     }
 }

 */
