//
//  UserValidatorTests.swift
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

final class UserValidatorTests: XCTestCase {

    var app: Application!
    var userValidator: UserValidator!
    var jwtValidator = MockJWTValidatorProtocol()

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        userValidator = UserValidator(jwtValidator: jwtValidator)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Validate Create Tests

    func testValidateCreate_WithAdminUser_ShouldReturnCreateContent() throws {
        // Mock JWT validation to return a payload with admin privileges
        let user = User.Stub.admin
        let payload = UserJWTPayload(user: user)
        
        given(jwtValidator).validateToken(.any).willReturn(payload)
        
        // Create a valid UserRequest.Create content
        let createUserRequest = UserRequest.Create(username: "newuser",
                                                   password: "password123",
                                                   fullname: "New User")
        let request = mockRequest(content: createUserRequest)


        // Validate and check the result
        let result = try userValidator.validateCreate(request)
        XCTAssertEqual(result.username, createUserRequest.username)
        XCTAssertEqual(result.password, createUserRequest.password)
        XCTAssertEqual(result.fullname, createUserRequest.fullname)
    }

    func testValidateCreate_WithNonAdminUser_ShouldThrowUnauthorizedError() throws {
        // Mock JWT validation to return a payload without admin privileges
        let user = User.Stub.user1
        let payload = UserJWTPayload(user: user)
        
        given(jwtValidator).validateToken(.any).willReturn(payload)

        let createUserRequest = UserRequest.Create(username: "newuser",
                                                   password: "password123",
                                                   fullname: "New User")
        let request = mockRequest(content: createUserRequest)

        do {
            let _ = try userValidator.validateCreate(request)
            
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? DefaultError, DefaultError.unauthorized)
        }
    }

    // MARK: - Validate Update Tests

    func testValidateUpdate_WithAdminUser_ShouldReturnUpdateContent() throws {
        // Mock JWT validation to return a payload with admin privileges
        let user = User.Stub.admin
        let payload = UserJWTPayload(user: user)
        
        given(jwtValidator).validateToken(.any).willReturn(payload)

        // Create a valid UserRequest.Update content
        let updateUserRequest = UserRequest.Update(fullname: "Updated User")
        let request = mockRequest(url: "/mock/:id", 
                                  pathParameters: ["id": UUID()],
                                  content: updateUserRequest)

        // Validate and check the result
        let result = try userValidator.validateUpdate(request)
        XCTAssertEqual(result.content.fullname, updateUserRequest.fullname)
    }

    func testValidateUpdate_WithNonAdminUser_ShouldThrowUnauthorizedError() throws {
        // Mock JWT validation to return a payload without admin privileges
        let user = User.Stub.user1
        let payload = UserJWTPayload(user: user)
        
        given(jwtValidator).validateToken(.any).willReturn(payload)

        let updateUserRequest = UserRequest.Update(fullname: "Updated User")
        let request = mockRequest(url: "/mock/:id", 
                                  pathParameters: ["id": UUID()],
                                  content: updateUserRequest)

        do {
            let _ = try userValidator.validateUpdate(request)
            
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? DefaultError, DefaultError.unauthorized)
        }
    }

}
