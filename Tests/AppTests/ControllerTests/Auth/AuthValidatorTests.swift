//
//  AuthValidatorTests.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//
import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class AuthValidatorTests: XCTestCase {

    var app: Application!
    var validator: AuthValidator!

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        validator = AuthValidator()
        
        //config key and hash method
        app.jwt.signers.use(.hs256(key: getJWTKey()))
        app.passwords.use(.bcrypt)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Validate Payload Tests
//
//    func testValidatePayload_WithValidToken_ShouldReturnPayload() throws {
//        let user = User(id: UUID(),
//                        username: "testUser",
//                        passwordHash: "pwd",
//                        personalInformation: .init(fullname: "Test User"))
//    
//        let payload = UserJWTPayload(user: user)
//        let token = try mockGETRequest(app: app).jwt.sign(payload)
//        let request = mockRequest(app: app,
//                                  method: .POST,
//                                  url: "auth",
//                                  header: [
//                                    ("Authorization", "Bearer \(token)"),
//                                    ("Content-Type", "application/json")
//                                  ],
//                                  content: user)
//
//        XCTAssertNoThrow(try validator.validatePayload(request))
//    }
//    
//    func testValidatePayload_WithMissingHeader_ShouldThrowError() throws {
//        let user = User(id: UUID(),
//                        username: "testUser",
//                        passwordHash: "pwd",
//                        personalInformation: .init(fullname: "Test User"))
//        
//        let request = mockRequest(app: app,
//                                  method: .POST,
//                                  url: "auth",
//                                  content: user)
//
//        XCTAssertThrowsError(try validator.validatePayload(request))
//    }
//
//    func testValidatePayload_WithInvalidToken_ShouldThrowError() throws {
//            let user = User(id: UUID(),
//                            username: "testUser",
//                            passwordHash: "pwd",
//                            personalInformation: .init(fullname: "Test User"))
//                    
//            let request = mockRequest(app: app,
//                                      method: .POST,
//                                      url: "auth",
//                                      header: [
//                                        ("Authorization", "Bearer bad_token"),
//                                        ("Content-Type", "application/json")
//                                      ],
//                                      content: user)
//        
//        XCTAssertThrowsError(try validator.validatePayload(request))
//    }

    // MARK: - Validate Sign-In Tests

    func testValidateSignIn_WithValidRequest_ShouldReturnSignIn() {
        let content = AuthRequest.SignIn(username: "testUser", password: "password123")
        let request = mockRequest(content: content)

        XCTAssertNoThrow(try validator.validateSignIn(request))
    }

    func testValidateSignIn_WithInvalidRequest_ShouldThrowError() {
        let content = AuthRequest.SignIn(username: "", password: "password123")
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateSignIn(request))
    }
    
    func testValidateSignIn_WithEmptyPassword_ShouldThrowError() {
        let content = AuthRequest.SignIn(username: "testUser", password: "")
        let request = mockRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateSignIn(request))
    }

    // MARK: - Validate Token Not Expired Tests
//
//    func testValidateTokenNotExpired_WithExpiredDate_ShouldThrow() {
//        let now = Date()
//        let expired = now.addingTimeInterval(-60)
//        let user = User(id: UUID(),
//                        username: "testUser",
//                        passwordHash: "pwd",
//                        tokenExpried: expired)
//        do {
//            try validator.validateTokenNotExpried(user)
//            XCTFail("Should have thrown error")
//        } catch {
//            XCTAssertEqual(error as! AuthError, AuthError.tokenExpired)
//        }
//    }
//    
//    func testValidateTokenNotExpired_WithNotExpiredDate_ShouldThrow() {
//        let now = Date()
//        let expired = now.addingTimeInterval(60)
//        let user = User(id: UUID(),
//                        username: "testUser",
//                        passwordHash: "pwd",
//                        tokenExpried: expired)
//        XCTAssertNoThrow(try validator.validateTokenNotExpried(user))
//    }

    // MARK: - Validate Password Tests

    func testValidatePassword_WithCorrectPassword_ShouldNoThrow() {
        let content = AuthRequest.SignIn(username: "", password: "password123")
        let request = mockRequest(content: content)
        
        let hashPwd = try! request.password.hash("password123")
        XCTAssertNoThrow(try validator.validatePassword(request,
                                                        pwd: content.password,
                                                        hashPwd: hashPwd))
    }

    func testValidatePassword_WithIncorrectPassword_ShouldThrowError() {
        let content = AuthRequest.SignIn(username: "", password: "password123")
        let request = mockRequest(content: content)
        
        let hashPwd = try! request.password.hash("password123")
        
        do {
            try validator.validatePassword(request,
                                           pwd: "wrongPassword",
                                           hashPwd: hashPwd)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual(error as! AuthError, AuthError.invalidUsernameOrPassword)
        }
    }
    
}
