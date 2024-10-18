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
    
    private(set) var repository: AuthRepositoryProtocol
    private(set) var userRepository: UserRepositoryProtocol
    private(set) var jwtRepository: JWTRepositoryProtocol
    
    private(set) var validator: AuthValidatorProtocol
    private(set) var jwtValidator: JWTValidatorProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository(),
         userRepository: UserRepositoryProtocol = UserRepository(),
         jwtRepository: JWTRepositoryProtocol = JWTRepository(),
         validator: AuthValidatorProtocol = AuthValidator(),
         jwtValidator: JWTValidatorProtocol = JWTValidator()) {
        self.repository = repository
        self.userRepository = userRepository
        self.jwtRepository = jwtRepository
        self.validator = validator
        self.jwtValidator = jwtValidator
    }
    
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post(use: signinJWT)
        
        auth.post("login-apple", use: signinWithApple)

        
        auth.group("token_verify") { authVerify in
            authVerify.post(use: verifyToken)
        }
        
        auth.group("logout") { authLogout in
            authLogout.post(use: logout)
        }
    }

    // POST /auth/login-apple
    func signinWithApple(req: Request) async throws -> [String: String] {

        // client call to https://appleid.apple.com/auth/token
        //let client = try req.client()
        //let content = try req.content.decode(AuthRequest.SignInApple.self)
        
        // let path = "Sources/App/Controllers/Auth/AuthKey_K9U9M59K86.p8"
        
        // let buffer = try await req.fileio.collectFile(at: path)
        // print(buffer)
        
//        let filePath = "Sources/App/Controllers/Auth/AuthKey_K9U9M59K86.p8"
//        let privateKeyData = try await req.fileio.readFile(at: filePath)
//        let privateKeyString = String(data: privateKeyData, encoding: .utf8) ?? ""
        
        // Read the file asynchronously
       
        let myJWT = try AppleSignInPayload.generateAppleClientSecret()

        // 001_032.369cf96334b140a6944e1794a90ea98c .1215

        // let appleTokenResponse = try await client.post("https://appleid.apple.com/auth/token") { req in
        //     try req.content.encode(content)
        // }


        // let content = try validator.validateSignInWithApple(req)
        
        // let foundUser = try await userRepository.fetchByUsername(request: .init(username: content.username),
        //                                                          on: req.db)
        // // generate new token
        // let (token, payload) = try jwtRepository.generateToken(request: .init(user: foundUser),
        //                                                        req: req)
        
        // // update and save user token
        // let updateUser = try await userRepository.updateToken(byId: .init(id: payload.userID),
        //                                                       request: .init(token: token,
        //                                                                      expiration: payload.expiration.value),
        //                                                       on: req.db)
                
        // // return new token
        // return ["token": updateUser.token ?? ""]
        return ["token": myJWT]
    }
    
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
        
        // update and save user token
        let updateUser = try await userRepository.updateToken(byId: .init(id: payload.userID),
                                                              request: .init(token: token,
                                                                             expiration: payload.expiration.value),
                                                              on: req.db)
                
        // return new token
        return ["token": updateUser.token ?? ""]
    }
    
    // POST /user/token_verify
    func verifyToken(req: Request) async throws -> HTTPStatus {
        let _ = try jwtValidator.validateToken(req)
        
        return .ok
    }
    
    //POST /user/logout
    func logout(req: Request) async throws -> HTTPStatus {
        let payload: UserJWTPayload = try jwtValidator.validateToken(req)
        let _ = try await userRepository.clearToken(byId: .init(id: payload.userID),
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


