//
//  UserControllerTests.swift
//
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class UserControllerTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    lazy var repo = MockUserRepositoryProtocol()
    lazy var validator = MockUserValidatorProtocol()
    
    var controller: UserController!
    
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
        
        try await dropCollection(db,
                                 schema: User.schema)
        
        // Register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }
    
    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Test POST /users
    func testCreate_WithEmptyUsername_ShouldReturnBadRequest() async throws {
        
        // Given
        let request = UserRequest.Create(username: "",
                                         password: "password",
                                         fullname: "Test User")
        given(validator).validateCreate(.any).willReturn(request)
        
        given(repo).create(request: .matching({ $0.username == request.username }),
                           env: .any,
                           on: .any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "users",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidUsername_ShouldReturnUser() async throws {
        
        // Given
        let request = UserRequest.Create(username: "testuser",
                                         password: "password",
                                         fullname: "Test User")
        let stub = User(id: UUID(),
                        username: request.username,
                        passwordHash: "hashedPassword",
                        personalInformation: .init(fullname: request.fullname),
                        userType: .user)
        
        given(validator).validateCreate(.any).willReturn(request)
        given(repo).create(request: .matching({ $0.username == request.username }),
                           env: .any,
                           on: .any).willReturn(stub)
        
        try app.test(.POST, "users",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertEqual(user.username, "testuser")
            XCTAssertEqual(user.personalInformation.fullname, "Test User")
        }
    }
    
    // MARK: - Test PUT /users/:id
    func testUpdate_WithInvalidUserID_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        let requestUpdate = UserRequest.Update(fullname: "Updated User")
        given(validator).validateUpdate(.any).willReturn((GeneralRequest.FetchById(id: id), requestUpdate))
        
        given(repo).update(byId: .matching({
            $0.id.uuidString == id.uuidString
        }),request: .matching({
            $0.fullname == requestUpdate.fullname
        }),on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.PUT, "users/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUpdate_WithValidUserID_ShouldReturnUser() async throws {
        
        // Given
        let id = UUID()
        let requestUpdate = UserRequest.Update(fullname: "Updated User")
        let stub = User(id: id,
                        username: "testuser",
                        passwordHash: "hashedPassword",
                        personalInformation: .init(fullname: requestUpdate.fullname),
                        userType: .user)
        
        given(validator).validateUpdate(.any).willReturn((GeneralRequest.FetchById(id: id), requestUpdate))
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.fullname == requestUpdate.fullname }),
                           on: .any).willReturn(stub)
        
        try app.test(.PUT, "users/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertEqual(user.personalInformation.fullname, "Updated User")
        }
    }
    
    // MARK: - Test DELETE /users/:id
    func testDelete_WithInvalidUserID_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        given(validator).validateUpdate(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.DELETE, "users/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testDelete_WithNotExistID_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let reqId = GeneralRequest.FetchById(id: id)
        let content = UserRequest.Update(fullname: "Updated User")
        
        given(validator).validateUpdate(.any).willReturn((reqId, content))
        
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willThrow(DefaultError.notFound)
        
        try app.test(.DELETE, "users/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testDelete_WithValidUserID_ShouldReturnUser() async throws {
        
        // Given
        let id = UUID()
        let reqId = GeneralRequest.FetchById(id: id)
        let stub = User(id: id,
                        username: "testuser",
                        passwordHash: "hashedPassword",
                        personalInformation: .init(fullname: "Test User"),
                        userType: .user,
                        deletedAt: .now)
        
        let content = UserRequest.Update(fullname: "Updated User")
        
        given(validator).validateUpdate(.any).willReturn((reqId, content))
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willReturn(stub)
        
        try app.test(.DELETE, "users/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertEqual(user.username, "testuser")
            XCTAssertNotNil(user.deletedAt)
        }
    }
    
    // MARK: - Test GET /users/me
    func testMe_WithValidRequest_ShouldReturnUser() async throws {
        
        // Given
        let id = UUID()
        let stub = User(id: id,
                        username: "testuser",
                        passwordHash: "hashedPassword",
                        personalInformation: .init(fullname: "Test User"),
                        userType: .user)
        
        let requestId = GeneralRequest.FetchById(id: id)
        let updateRequest = UserRequest.Update(fullname: "Test User")
        given(validator).validateUpdate(.any).willReturn((requestId, updateRequest))
        given(repo).fetchById(request: .matching({ $0.id == id }),
                              on: .any).willReturn(stub)
        
        try app.test(.GET, "users/me") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.self)
            XCTAssertEqual(user.username, "testuser")
            XCTAssertEqual(user.personalInformation.fullname, "Test User")
        }
    }
}

// MARK: - Stub and Mock

extension UserControllerTests {
    struct Stub {
        static var user: User {
            .init(username: "testuser", 
                  passwordHash: "hashedPassword",
                  personalInformation: .init(fullname: "Test User"))
        }
    }
    
}
