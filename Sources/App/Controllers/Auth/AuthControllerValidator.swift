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
    
    func validateTokenNotExpried(_ user: User,
                                 now: Date) -> Bool
    
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
            try AuthController.SignIn.validate(content: content)
            
            let signIn = try content.content.decode(AuthController.SignIn.self)
            return signIn
        } catch {
            throw AuthError.invalidUsernameOrPassword
        }
    }
    
    func validateTokenNotExpried(_ user: User,
                                 now: Date = .init()) -> Bool {
        guard
            let tokenExpried = user.tokenExpried
        else { return false }
        
        return tokenExpried <= now
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
