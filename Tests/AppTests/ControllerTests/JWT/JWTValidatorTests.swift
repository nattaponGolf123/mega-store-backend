//
//  JWTValidatorTests.swift
//  
//
//  Created by IntrodexMac on 18/8/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class JWTValidatorTests: XCTestCase {

    var app: Application!
    var jwtValidator: JWTValidator!

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        
        // setup JWT key
        app.jwt.signers.use(.hs256(key: getJWTKey()))
        app.passwords.use(.bcrypt)
        
        jwtValidator = JWTValidator()
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Validate Token Tests

    func testValidateToken_WithValidToken_ShouldReturnPayload() throws {
        let user = User.Stub.admin
        let expirationDate = Date().addingTimeInterval(3600) // 1 hour in the future
        let payload = UserJWTPayload(subject: .init(value: "mega-store-user"),
                                     expiration: .init(value: expirationDate),
                                     userID: user.id ?? .init(),
                                     username: user.username,
                                     userFullname: user.personalInformation.fullname,
                                     isAdmin: user.type == UserType.admin)
        
        let jwt = try mockRequest(app: app).jwt.sign(payload)
        let request = mockRequest(app: app,
                                  header: [
            ("Authorization", "Bearer \(jwt)"),
            ("Content-Type", "application/json")
        ])
        XCTAssertNoThrow(try jwtValidator.validateToken(request))
    }

    func testValidateToken_WithExpiredToken_ShouldThrowTokenExpiredError() throws {
        let user = User.Stub.admin
        let expirationDate = Date().addingTimeInterval(-3600) // 1 hour in the past
        let payload = UserJWTPayload(subject: .init(value: "mega-store-user"),
                                     expiration: .init(value: expirationDate),
                                     userID: user.id ?? .init(),
                                     username: user.username,
                                     userFullname: user.personalInformation.fullname,
                                     isAdmin: user.type == UserType.admin)
        
        let jwt = try mockRequest(app: app).jwt.sign(payload)
        let request = mockRequest(app: app,
                                  header: [
            ("Authorization", "Bearer \(jwt)"),
            ("Content-Type", "application/json")
        ])
        do {
            let _ = try jwtValidator.validateToken(request)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(error as! AuthError, AuthError.tokenExpired)
        }
    }

    func testValidateToken_WithInvalidToken_ShouldThrowInvalidTokenError() {
        let request = mockRequest(app: app,
                                  header: [
            ("Authorization", "Bearer invalidToken"),
            ("Content-Type", "application/json")
        ])
        
        do {
            let _ = try jwtValidator.validateToken(request)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(error as! AuthError, AuthError.invalidToken)
        }
    }
}
