//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor
import Mockable

@Mockable
protocol AuthValidatorProtocol {
    //func validatePayload(_ content: Request) throws -> UserJWTPayload
    func validateSignIn(_ content: Request) throws -> AuthRequest.SignIn
    func validatePassword(_ content: Request,
                          pwd: String,
                          hashPwd: String) throws
//    func validateTokenNotExpried(_ user: User,
//                                 now: Date) throws
    
//    func validatePassword(_ content: Request,
//                          pwd: String,
//                          hashPwd: String) throws -> Bool
    
//    func validateTokenNotExpried(_ user: User,
//                                 now: Date) -> Bool
    
    //func validateToken(_ content: Request) throws -> Bool
//    func validatePassword(_ content: Request,
//                          pwd: String) throws -> Bool
}

class AuthValidator: AuthValidatorProtocol {
    
//    func validatePayload(_ content: Request) throws -> UserJWTPayload {
//        do {
//            return try content.jwt.verify(as: UserJWTPayload.self)
//        } catch {
//            throw AuthError.invalidToken
//        }
//    }
    
    func validateSignIn(_ content: Request) throws -> AuthRequest.SignIn {
        do {
            try AuthRequest.SignIn.validate(content: content)
            
            let signIn = try content.content.decode(AuthRequest.SignIn.self)
            return signIn
        } catch {
            throw AuthError.invalidUsernameOrPassword
        }
    }
    
//    func validateTokenNotExpried(_ user: User,
//                                 now: Date = .init()) -> Bool {
//        guard
//            let tokenExpried = user.tokenExpried
//        else { return false }
//        
//        return tokenExpried <= now
//    }
//    
//    func validateTokenNotExpried(_ user: User,
//                                 now: Date = .init()) throws {
//        guard
//            let tokenExpried = user.tokenExpried
//        else { throw AuthError.invalidToken }
//        
//        guard 
//            tokenExpried >= now
//        else { throw AuthError.tokenExpired }
//    }
    
    func validatePassword(_ content: Request,
                          pwd: String,
                          hashPwd: String) throws {
        let result = try content.password.verify(pwd,
                                           created: hashPwd)
        guard 
            result
        else { throw AuthError.invalidUsernameOrPassword }
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
