//
//  UserRepositoryTests.swift
//  
//
//  Created by IntrodexMac on 18/8/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver

@testable import App

final class UserRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    var userRepository: UserRepository!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: UserMigration())
        
        db = app.db
        
        userRepository = UserRepository()
        
        try await dropCollection(db,
                                 schema: User.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    //MARK: fetchById
    func testFetchById_ShouldReturnUser() async throws {
        
        // Given
        let user = Stub.user
        try await user.create(on: db)
        
        // When
        let result = try await userRepository.fetchById(request: .init(id: user.id!), on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.username, "testUser")
    }
    
    func testFetchById_WithInvalidId_ShouldThrowError() async throws {
        
        // Given
        let invalidId = UUID()
        
        // When / Then
        do {
            _ = try await userRepository.fetchById(request: .init(id: invalidId), on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: fetchByUsername
    func testFetchByUsername_ShouldReturnUser() async throws {
        
        // Given
        let user = User(username: "testUser", passwordHash: "hashedPassword", personalInformation: .init(fullname: "Test User"), userType: .user)
        try await user.create(on: db)
        
        // When
        let result = try await userRepository.fetchByUsername(request: .init(username: "testUser"), on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.username, "testUser")
    }
    
    func testFetchByUsername_WithInvalidUsername_ShouldThrowError() async throws {
        
        // Given
        let invalidUsername = "nonExistentUser"
        
        // When / Then
        do {
            _ = try await userRepository.fetchByUsername(request: .init(username: invalidUsername), on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: create
    func testCreate_ShouldCreateUser() async throws {
        
        // Given
        let request = UserRequest.Create(username: "testUser", password: "password123", fullname: "Test User")
        
        // When
        let result = try await userRepository.create(request: request, on: db)
        
        // Then
        XCTAssertEqual(result.username, "testUser")
    }
    
    func testCreate_WithDuplicateUsername_ShouldThrowError() async throws {
        
        // Given
        let user = Stub.user
        try await user.create(on: db)
        
        let request = UserRequest.Create(username: "testUser", password: "password123", fullname: "Another User")
        
        // When / Then
        do {
            _ = try await userRepository.create(request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? CommonError, .duplicateUsername)
        }
    }
    
    //MARK: update
    func testUpdate_ShouldUpdateUser() async throws {
        
        // Given
        let user = User(username: "testUser", passwordHash: "hashedPassword", personalInformation: .init(fullname: "Old Name"), userType: .user)
        try await user.create(on: db)
        
        let request = UserRequest.Update(fullname: "New Name")
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When
        let result = try await userRepository.update(byId: fetchById, request: request, on: db)
        
        // Then
        XCTAssertEqual(result.personalInformation.fullname, "New Name")
    }
    
    func testUpdate_WithInvalidId_ShouldThrowError() async throws {
        
        // Given
        let request = UserRequest.Update(fullname: "New Name")
        let fetchById = GeneralRequest.FetchById(id: UUID())
        
        // When / Then
        do {
            _ = try await userRepository.update(byId: fetchById, request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: delete
    func testDelete_ShouldDeleteUser() async throws {
        
        // Given
        let user = Stub.user
        try await user.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When
        let result = try await userRepository.delete(byId: fetchById, on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
    
    func testDelete_WithInvalidId_ShouldThrowError() async throws {
        
        // Given
        let fetchById = GeneralRequest.FetchById(id: UUID())
        
        // When / Then
        do {
            _ = try await userRepository.delete(byId: fetchById, on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: clearToken
    func testClearToken_ShouldClearUserToken() async throws {
        
        // Given
        let user = Stub.user
        user.setToken("token123", expried: Date().addingTimeInterval(3600))
        try await user.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When
        let result = try await userRepository.clearToken(byId: fetchById, on: db)
        
        // Then
        XCTAssertNil(result.token)
        XCTAssertNil(result.tokenExpried)
    }
    
    //MARK: updateToken
    func testUpdateToken_ShouldUpdateUserToken() async throws {
        
        // Given
        let user = Stub.user
        try await user.create(on: db)
        
        let request = UserRequest.UpdateToken(token: "newToken123", expiration: Date().addingTimeInterval(3600))
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When
        let result = try await userRepository.updateToken(byId: fetchById, request: request, on: db)
        
        // Then
        XCTAssertEqual(result.token, "newToken123")
        XCTAssertNotNil(result.tokenExpried)
    }
    
    //MARK: verifyExistToken
    func testVerifyExistToken_WithValidToken_ShouldNotThrowError() async throws {
        
        // Given
        let user = Stub.user
        user.setToken("token123", expried: Date().addingTimeInterval(3600))
        try await user.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When / Then
        do {
            try await userRepository.verifyExistToken(byId: fetchById, on: db)
        } catch {
            XCTFail("Should not throws")
        }
    }
    
    func testVerifyExistToken_WithNotExistToken_ShouldThrowError() async throws {
        
        // Given
        let user = Stub.user
        
        try await user.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: user.id!)
        
        // When / Then
        do {
            _ = try await userRepository.verifyExistToken(byId: fetchById, on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidToken)
        }
    }
}

private extension UserRepositoryTests {
    struct Stub {
        static var user: User {
            User(username: "testUser",
                 passwordHash: "hashedPassword",
                 personalInformation: .init(fullname: "Test User"),
                 userType: .user)
        }
    }
}
