//
//  AuthControllerTests.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import XCTest
import Vapor
import Fluent
import Mockable
import MockableTest

@testable import App

final class AuthControllerTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    // Database configuration
    var dbHost: String!
    
    var repo: MockAuthRepositoryProtocol!
    var userRepo: MockUserRepositoryProtocol!
    var jwtRepo: MockJWTRepositoryProtocol!
    var validator: MockAuthValidatorProtocol!
    var jwtValidator: MockJWTValidatorProtocol!
    var controller: AuthController!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: UserMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: User.schema)
        
        repo = MockAuthRepositoryProtocol()
        userRepo = MockUserRepositoryProtocol()
        jwtRepo = MockJWTRepositoryProtocol()
        validator = MockAuthValidatorProtocol()
        jwtValidator = MockJWTValidatorProtocol()
        
        controller = AuthController(repository: repo,
                                    userRepository: userRepo,
                                    jwtRepository: jwtRepo,
                                    validator: validator,
                                    jwtValidator: jwtValidator)
        
        try app.register(collection: controller)
    }
    
    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests POST /auth
    
    func testSignInJWT_WithInvalidCredentials_ShouldReturnBadRequest() async throws {
        // Given
        given(validator).validateSignIn(.any).willThrow(AuthError.invalidUsernameOrPassword)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSignInJWT_WithValidCredentials_ShouldReturnToken() async throws {
        // Given
        let signInRequest = AuthRequest.SignIn(username: "testuser", password: "password")
                
        //tokenExpried + 1 day
        let tokenExpried = Date().addingTimeInterval(60*60*24)
        
        let user = User(id: UUID(),
                        username: "testuser",
                        passwordHash: "hashedPassword",
                        token: "token123",
                        tokenExpried: tokenExpried)
        let jwtPayload = UserJWTPayload(user: user)
        
        given(validator).validateSignIn(.any).willReturn(signInRequest)
        given(userRepo).fetchByUsername(request: .matching({ $0.username == "testuser" }),
                                        on: .any).willReturn(user)
        given(validator).validatePassword(.any,
                                          pwd: .any,
                                          hashPwd: .any).willReturn()
        given(jwtRepo).generateToken(request: .matching({ $0.user.username == "testuser" }),
                                     req: .any).willReturn(("token123", jwtPayload))
        
        given(userRepo).updateToken(byId: .matching({ $0.id == user.id }),
                                    request: .any,
                                    on: .any).willReturn(user)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .ok)
            let tokenResponse = try res.content.decode([String: String].self)
            XCTAssertEqual(tokenResponse["token"], "token123")
        }
    }
    
    func testSignInJWT_WithValidateSignInFail_ShouldReturnBadRequest() async throws {
        // Given
        given(validator).validateSignIn(.any).willThrow(AuthError.invalidUsernameOrPassword)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSignInJWT_WithFetchByUsernameNotFound_ShouldReturnUnauthorized() async throws {
        // Given
        let signInRequest = AuthRequest.SignIn(username: "testuser", password: "password")
        
        given(validator).validateSignIn(.any).willReturn(signInRequest)
        given(userRepo).fetchByUsername(request: .matching({ $0.username == "testuser" }),
                                        on: .any).willThrow(AuthError.userNotFound)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testSignInJWT_WithGenerateTokenFail_ShouldReturnBadRequest() async throws {
        // Given
        let signInRequest = AuthRequest.SignIn(username: "testuser", password: "password")
        
        let user = User(id: UUID(),
                        username: "testuser",
                        passwordHash: "hashedPassword")
        
        given(validator).validateSignIn(.any).willReturn(signInRequest)
        given(userRepo).fetchByUsername(request: .matching({ $0.username == "testuser" }),
                                        on: .any).willReturn(user)
        given(validator).validatePassword(.any,
                                          pwd: .any,
                                          hashPwd: .any).willReturn()
        given(jwtRepo).generateToken(request: .matching({ $0.user.username == "testuser" }),
                                     req: .any).willThrow(AuthError.invalidToken)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testSignInJWT_WithUpdateTokenFail_ShouldReturnBadRequest() async throws {
        // Given
        let signInRequest = AuthRequest.SignIn(username: "testuser", password: "password")
        
        let user = User(id: UUID(),
                        username: "testuser",
                        passwordHash: "hashedPassword")
        
        let jwtPayload = UserJWTPayload(user: user)
        
        given(validator).validateSignIn(.any).willReturn(signInRequest)
        given(userRepo).fetchByUsername(request: .matching({ $0.username == "testuser" }),
                                        on: .any).willReturn(user)
        given(validator).validatePassword(.any,
                                          pwd: .any,
                                          hashPwd: .any).willReturn()
        given(jwtRepo).generateToken(request: .matching({ $0.user.username == "testuser" }),
                                     req: .any).willReturn(("token123", jwtPayload))
        
        given(userRepo).updateToken(byId: .matching({ $0.id == user.id }),
                                    request: .any,
                                    on: .any).willThrow(AuthError.invalidToken)
        
        // When
        try app.test(.POST, "auth") { res in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    // MARK: - Tests POST /auth/token_verify
    
    func testVerifyToken_WithInvalidToken_ShouldReturnUnauthorized() async throws {
        // Given
        given(jwtValidator).validateToken(.any).willThrow(AuthError.invalidToken)
        
        // When
        try app.test(.POST, "auth/token_verify") { res in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testVerifyToken_WithValidToken_ShouldReturnOK() async throws {
        // Given
        let userPayload = UserJWTPayload(user: User(id: UUID(), username: "testuser", passwordHash: "hashedPassword"))
        
        given(jwtValidator).validateToken(.any).willReturn(userPayload)
        
        // When
        try app.test(.POST, "auth/token_verify") { res in
            // Then
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    // MARK: - Tests POST /auth/logout
    
    func testLogout_WithInvalidToken_ShouldReturnUnauthorized() async throws {
        // Given
        given(jwtValidator).validateToken(.any).willThrow(AuthError.invalidToken)
        
        // When
        try app.test(.POST, "auth/logout") { res in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testLogout_WithValidToken_ShouldReturnOK() async throws {
        // Given
        let user = User(id: UUID(), username: "testuser", passwordHash: "hashedPassword")
        let userPayload = UserJWTPayload(user: user)
        
        given(jwtValidator).validateToken(.any).willReturn(userPayload)
        given(userRepo).clearToken(byId: .matching({ $0.id == user.id }),
                                   on: .any).willReturn(user)
        
        // When
        try app.test(.POST, "auth/logout") { res in
            // Then
            XCTAssertEqual(res.status, .ok)
        }
    }
}


/*
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
         
         auth.group("token_verify") { authVerify in
             authVerify.post(use: verifyToken)
         }
         
         auth.group("logout") { authLogout in
             authLogout.post(use: logout)
         }
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



 */
