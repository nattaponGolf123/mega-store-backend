//
//  JWTRepositoryTests.swift
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

final class JWTRepositoryTests: XCTestCase {

    var app: Application!
    var jwtRepository: JWTRepository!

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        
        // setup JWT key
        app.jwt.signers.use(.hs256(key: getJWTKey()))
        app.passwords.use(.bcrypt)
        
        jwtRepository = JWTRepository()
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Generate Token Tests

    func testGenerateToken_WithValidRequest_ShouldReturnTokenAndPayload() throws {
        let user = User.Stub.admin
        let requestContent = JWTRequest.GenerateToken(user: user)
        let request = mockRequest(app: app)

        let (token, payload) = try jwtRepository.generateToken(request: requestContent, req: request)

        // Assert that the token is not empty
        XCTAssertFalse(token.isEmpty)

        // Assert that the payload matches the user
        XCTAssertEqual(payload.userID, user.id)
        XCTAssertEqual(payload.username, user.username)
        XCTAssertEqual(payload.userFullname, user.personalInformation.fullname)
        XCTAssertEqual(payload.isAdmin, user.type == .admin)

        // Verify the token can be decoded back to the payload
        let decodedPayload = try request.jwt.verify(token, as: UserJWTPayload.self)
        XCTAssertEqual(decodedPayload.userID, payload.userID)
        XCTAssertEqual(decodedPayload.username, payload.username)
        XCTAssertEqual(decodedPayload.userFullname, payload.userFullname)
        XCTAssertEqual(decodedPayload.isAdmin, payload.isAdmin)
    }

    func testGenerateToken_WithDifferentUser_ShouldReturnCorrectPayload() throws {
        let user = User(username: "testUser", 
                        passwordHash: "hashedPassword",
                        personalInformation: .init(fullname: "Test User"),
                        userType: .user)
        let requestContent = JWTRequest.GenerateToken(user: user)
        let request = mockRequest(app: app)

        let (token, payload) = try jwtRepository.generateToken(request: requestContent, req: request)

        // Assert that the token is not empty
        XCTAssertFalse(token.isEmpty)

        // Assert that the payload matches the user
        XCTAssertEqual(payload.userID, user.id)
        XCTAssertEqual(payload.username, user.username)
        XCTAssertEqual(payload.userFullname, user.personalInformation.fullname)
        XCTAssertEqual(payload.isAdmin, user.type == .admin)

        // Verify the token can be decoded back to the payload
        let decodedPayload = try request.jwt.verify(token, as: UserJWTPayload.self)
        XCTAssertEqual(decodedPayload.userID, payload.userID)
        XCTAssertEqual(decodedPayload.username, payload.username)
        XCTAssertEqual(decodedPayload.userFullname, payload.userFullname)
        XCTAssertEqual(decodedPayload.isAdmin, payload.isAdmin)
    }
}
