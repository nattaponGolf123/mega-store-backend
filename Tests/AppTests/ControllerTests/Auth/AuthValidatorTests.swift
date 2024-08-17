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

final class AuthControllerValidatorTests: XCTestCase {

    var app: Application!
    var validator: AuthControllerValidator!

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        validator = AuthControllerValidator()
        
        app.jwt.signers.use(.hs256(key: getJWTKey()))
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Validate Payload Tests

    func testValidatePayload_WithValidToken_ShouldReturnPayload() throws {
        let user = User(id: UUID(),
                        username: "testUser",
                        passwordHash: "pwd",
                        personalInformation: .init(fullname: "Test User"))
    
        let payload = UserJWTPayload(user: user)
        let token = try mockGETRequest(app: app).jwt.sign(payload)
        let request = mockRequest(app: app,
                                  method: .POST,
                                  url: "auth",
                                  header: [
                                    ("Authorization", "Bearer \(token)"),
                                    ("Content-Type", "application/json")
                                  ],
                                  content: user)

        XCTAssertNoThrow(try validator.validatePayload(request))
    }
    
    func testValidatePayload_WithMissingHeader_ShouldThrowError() throws {
        let user = User(id: UUID(),
                        username: "testUser",
                        passwordHash: "pwd",
                        personalInformation: .init(fullname: "Test User"))
    
        let payload = UserJWTPayload(user: user)
        
        let request = mockRequest(app: app,
                                  method: .POST,
                                  url: "auth",
                                  content: user)

        XCTAssertThrowsError(try validator.validatePayload(request))
    }

    func testValidatePayload_WithInvalidToken_ShouldThrowError() throws {
            let user = User(id: UUID(),
                            username: "testUser",
                            passwordHash: "pwd",
                            personalInformation: .init(fullname: "Test User"))
                    
            let request = mockRequest(app: app,
                                      method: .POST,
                                      url: "auth",
                                      header: [
                                        ("Authorization", "Bearer bad_token"),
                                        ("Content-Type", "application/json")
                                      ],
                                      content: user)
        
        XCTAssertThrowsError(try validator.validatePayload(request))
    }

    // MARK: - Validate Sign-In Tests

    func testValidateSignIn_WithValidRequest_ShouldReturnSignIn() {
        let content = AuthController.SignIn(username: "testUser", password: "password123")
        let request = mockRequest(content: content)

        XCTAssertNoThrow(try validator.validateSignIn(request))
    }

    func testValidateSignIn_WithInvalidRequest_ShouldThrowError() {
        let content = AuthController.SignIn(username: "", password: "password123")
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateSignIn(request))
    }

    // MARK: - Validate Token Not Expired Tests

    func testValidateTokenNotExpired_WithExpiredToken_ShouldReturnFalse() {
        let now = Date()
        let user = User(id: UUID(),
                        username: "testUser",
                        passwordHash: "pwd",
                        tokenExpried: now.addingTimeInterval(-60))
        
        XCTAssertFalse(validator.validateTokenNotExpried(user,
                                                         now: now))
    }

    func testValidateTokenNotExpired_WithValidToken_ShouldReturnTrue() {
        let user = User(id: UUID(), 
                        username: "testUser",
                        passwordHash: "pwd",
                        tokenExpried: Date().addingTimeInterval(60))
        
        XCTAssertTrue(validator.validateTokenNotExpried(user))
    }

    // MARK: - Validate Password Tests
//
//    func testValidatePassword_WithCorrectPassword_ShouldReturnTrue() {
//        let request = mockRequest()
//        let hashPwd = try! request.password.hash("password123")
//        
//        XCTAssertTrue(try validator.validatePassword(request, pwd: "password123", hashPwd: hashPwd))
//    }
//
//    func testValidatePassword_WithIncorrectPassword_ShouldReturnFalse() {
//        let request = mockRequest()
//        let hashPwd = try! request.password.hash("password123")
//        
//        XCTAssertFalse(try validator.validatePassword(request, pwd: "wrongpassword", hashPwd: hashPwd))
//    }
}
