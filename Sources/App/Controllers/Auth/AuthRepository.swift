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
import Mockable

@Mockable
protocol AuthRepositoryProtocol {
//    func fetch(request: GeneralRequest.FetchById,
//               on db: Database) async throws -> User
//    func fetch(request: AuthRequest.FetchByUsername,
//               on db: Database) async throws -> User
//    func signIn(request: AuthRequest.SignIn,
//                on db: Database) async throws -> User
//    func clearUserToken(request: GeneralRequest.FetchById,
//                    on db: Database) async throws -> User
//    func generateUserToken(request: AuthRequest.GenerateToken,
//                           on db: Database) async throws -> User
//    //
////    func generateToken(req: Request,
////                       user: User,
////                       on db: Database) async throws -> User
//    func verifyExistToken(request: GeneralRequest.FetchById,
//                          on db: Database) async throws
    
}

class AuthRepository: AuthRepositoryProtocol {
        
    private var userRepository: UserRepositoryProtocol
    private var jwtRepository: JWTRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserRepository(),
          jwtRepository: JWTRepositoryProtocol = JWTRepository()) {
        self.userRepository = userRepository
        self.jwtRepository = jwtRepository
    }
    
//    func fetch(request: GeneralRequest.FetchById,
//               on db: Database) async throws -> User {
//        return try await userRepository.fetchById(request: request, on: db)
//    }
//    
//    func fetch(request: AuthRequest.FetchByUsername,
//               on db: Database) async throws -> User {
//        .Stub.user1
//    }
    /*
     // POST /user
     func signinJWT(req: Request) async throws -> [String: String] {
         let content = try validator.validateSignIn(req)
         let foundUser = try await userRepository.fetchByUsername(request: .init(username: content.username),
                                                            on: req.db)
         //validate pwd
         try validator.validatePassword(req,
                                        pwd: content.password,
                                        hashPwd: foundUser.passwordHash)
         // generate new token
         let (token, payload) = try jwtRepository.generateToken(request: .init(user: foundUser),
                                                                req: req)
         
         
         // try to decode param by Auth
 //        let signIn = try validator.validateSignIn(req)
 //        let foundUser = try await repository.findUser(username: signIn.username,
 //                                                      on: req.db)
 //        try validator.validatePassword(req,
 //                                           pwd: signIn.password,
 //                                           hashPwd: foundUser.passwordHash)
 //
 //        let updatedUser = try await repository.generateToken(req: req,
 //                                                             user: foundUser,
 //                                                             on: req.db)
 //        return ["token": updatedUser.token ?? ""]
         return [:]
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
     */
//    func signIn(request: AuthRequest.SignIn,
//                on db: Database) async throws -> User {
//        let foundUser = try await userRepository.fetchByUsername(request: .init(username: request.username),
//                                                           on: db)
//        //validate pwd
//        try validator.validatePassword(req,
//                                       pwd: content.password,
//                                       hashPwd: foundUser.passwordHash)
//        // generate new token
//        let (token, payload) = try jwtRepository.generateToken(request: .init(user: foundUser),
//                                                               req: req)
//        
//    }
    
//    func clearToken(request: GeneralRequest.FetchById,
//                    on db: Database) async throws -> User {
//        .Stub.user1
//    }
//
//    func generateUserToken(request: AuthRequest.GenerateToken,
//                           on db: Database) async throws -> User {
//        //request.token
//        //request.payload
//        let userID = request.payload.userID
//        
//        
////        let user = try await userRepository.fetchById(request: .init(id: userID),
////                                                      on: db)
//        
//    }
//    
//    
//    func verifyExistToken(request: GeneralRequest.FetchById,
//                          on db: Database) async throws {
//        
//    }
    
//
//    func findUser(userID: UUID,
//                  on db: Database) async throws -> User {
//        guard
//            let foundUser = try await User.find(userID,
//                                                on: db)
//        else {
//            throw AuthError.userNotFound
//        }
//        
//        return foundUser
//    }
//    
//    func findUser(username: String,
//                  on db: Database) async throws -> User {
//        guard
//            let foundUser = try await User.query(on: db)
//                .filter(\.$username == username)
//                .first()
//        else {
//            throw AuthError.userNotFound
//        }
//        
//        return foundUser
//    }
//    
//    func clearToken(id: UUID,
//                    on db: Database) async throws -> User {
//        guard
//            let user = try await User.find(id,
//                                           on: db)
//        else { throw AuthError.userNotFound }
//        
//        user.clearToken()
//        try await user.save(on: db)
//        
//        return user
//    }
//    
//    func generateToken(req: Request,
//                       user: User,
//                       on db: Database) async throws -> User {
//        let payload = UserJWTPayload(user: user)
//        
//        let token = try req.jwt.sign(payload)
//        
//        user.setToken(token,
//                      expried: payload.expiration.value)
//        
//        try await user.save(on: db)
//        
//        return user
//    }
//    
//    func verifyExistToken(id: UUID,
//                          on db: Database) async throws {
//        let foundUser = try await findUser(userID: id,
//                                           on: db)
//        guard
//            let _ = foundUser.token,
//            let _ = foundUser.tokenExpried
//        else { throw AuthError.invalidToken }
//        
//    }

}
