//
//  ServiceCategoryControllerTests.swift
//  
//
//  Created by IntrodexMac on 23/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class ServiceCategoryControllerTests: XCTestCase {

    typealias Search = GeneralRequest.Search
    
    var app: Application!
    var db: Database!
    
    lazy var repo = MockServiceCategoryRepositoryProtocol()
    lazy var validator = MockServiceCategoryValidatorProtocol()
    
    var controller: ServiceCategoryController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ServiceCategoryMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: ServiceCategory.schema)
        
        //register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /service_categories
    func testAll_WithNoRequestParam_ShouldReturnEmptyGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.emptyPageGroup)
        
        try app.test(.GET, "service_categories") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ServiceCategory>.self)
            XCTAssertEqual(groups.items.count, 0)
        }
    }
        
    func testAll_WithNoRequestParam_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.pageGroup)
    
        try app.test(.GET, "service_categories") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ServiceCategory>.self)
            XCTAssertEqual(groups.items.count, 2)
        }
    }
    
    func testAll_WithShowDeleted_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .matching({ $0.showDeleted == true}),
                             on: .any).willReturn(Stub.pageGroupWithDeleted)
        
        try app.test(.GET, "service_categories?show_deleted=true") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ServiceCategory>.self)
            XCTAssertEqual(groups.items.count, 3)
        }
    }
    
    // MARK: - Test GET /service_categories/:id
    func testGetByID_WithID_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willThrow(DefaultError.notFound)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "service_categories/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
        
    }
    
    func testGetByID_WithMatchID_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willReturn(Stub.group)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "service_categories/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    // MARK: - Test POST /service_categories
    func testCreate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let request = ServiceCategoryRequest.Create(name: "")
        given(validator).validateCreate(.any).willReturn(request)
                
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "service_categories",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidName_ShouldReturnGroup() async throws {
        
        // Given
        let request = ServiceCategoryRequest.Create(name: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willReturn(Stub.group)
        
        try app.test(.POST, "service_categories",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testCreate_WithValidNameDescription_ShouldReturnGroup() async throws {
        
        // Given
        let request = ServiceCategoryRequest.Create(name: "Test",
                                                 description: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        let stub = ServiceCategory(id: .init(),
                                name: request.name,
                                description: request.description, 
                                createdAt: .now,
                                updatedAt: .now)
        given(repo).create(request: .matching({
            $0.name == request.name &&
            $0.description == request.description
        }),
                           on: .any).willReturn(stub)
        
        try app.test(.POST, "service_categories",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Test")
            XCTAssertEqual(group.description ?? "", "Test")
        }
    }
    
    // MARK: - Test PUT /service_categories/:id
    func testUpdate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = ServiceCategoryRequest.Update(name: "")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.PUT, "service_categories/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUpdate_WithValidName_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = ServiceCategoryRequest.Update(name: "Test")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willReturn(Stub.group)
        
        try app.test(.PUT, "service_categories/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testUpdate_WithValidNameDescription_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = ServiceCategoryRequest.Update(description: "Test")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        let stub = ServiceCategory(id: .init(),
                                name: "Name",
                                description: requestUpdate.description,
                                createdAt: .now,
                                updatedAt: .now)
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name &&
                                                $0.description == requestUpdate.description }),
                           on: .any).willReturn(stub)
        
        try app.test(.PUT, "service_categories/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Name")
            XCTAssertEqual(group.description ?? "", "Test")
        }
    }
    
    // MARK: - Test DELETE /service_categories/:id
    func testDelete_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        given(validator).validateID(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.DELETE, "service_categories/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testDelete_WithNotExistId_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let reqId = GeneralRequest.FetchById(id: id)
        given(validator).validateID(.any).willReturn(reqId)
        
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willThrow(DefaultError.notFound)
        
        try app.test(.DELETE, "service_categories/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testDelete_WithValidGroup_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let reqId = GeneralRequest.FetchById(id: id)
        given(validator).validateID(.any).willReturn(reqId)
        
        let stub = ServiceCategory(id: .init(),
                                name: "Name",
                                description: "Test",
                                createdAt: .now,
                                updatedAt: .now,
                                deletedAt: .now)
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willReturn(stub)
        
        try app.test(.DELETE, "service_categories/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ServiceCategory.self)
            XCTAssertEqual(group.name, "Name")
            XCTAssertEqual(group.description ?? "", "Test")
            XCTAssertNotNil(group.deletedAt)
        }
    }
    
    // MARK: - Test GET /service_categories/search
    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
        
        // Given
        let query = Search(query: "")
        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.GET, "service_categories/search") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSearch_WithMore200CharQuery_ShouldReturnBadRequest() async throws {
        
        // Given
        let query = Search(query: String(repeating: "A", count: 210))
        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.GET, "service_categories/search?query=\(query.query)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSearch_WithValidQuery_ShouldReturnEmptyGroups() async throws {
        
        // Given
        let query = Search(query: "Test")
        given(validator).validateSearchQuery(.any).willReturn(query)
        
        let stub = PaginatedResponse<ServiceCategory>(page: 1, perPage: 20, total: 0, items: [])
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willReturn(stub)
        
        try app.test(.GET, "service_categories/search?query=Test") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ServiceCategory>.self)
            XCTAssertEqual(groups.total, 0)
        }
    }
    
    func testSearch_WithValidQuery_ShouldReturnGroups() async throws {
        
        // Given
        let query = Search(query: "Test")
        given(validator).validateSearchQuery(.any).willReturn(query)
        
        let stub = PaginatedResponse<ServiceCategory>(page: 1, perPage: 20, total: 2,
                                                   items: [ServiceCategory(name: "Test 1"),
                                                           ServiceCategory(name: "Test 2")])
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willReturn(stub)
        
        try app.test(.GET, "service_categories/search?query=Test") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ServiceCategory>.self)
            XCTAssertEqual(groups.total, 2)
        }
    }
    
}

extension ServiceCategoryControllerTests {
    struct Stub {
        
        static var emptyPageGroup: PaginatedResponse<ServiceCategory> {
            .init(page: 1,
                  perPage: 10,
                  total: 0,
                  items: [])
        }
        
        static var pageGroup: PaginatedResponse<ServiceCategory> {
            .init(page: 1,
                  perPage: 10,
                  total: 2,
                  items: [ServiceCategory(name: "Supplier"),
                          ServiceCategory(name: "Manufactor")])
        }
        
        static var pageGroupWithDeleted: PaginatedResponse<ServiceCategory> {
            .init(page: 1,
                  perPage: 10,
                  total: 3,
                  items: [ServiceCategory(name: "Supplier"),
                          ServiceCategory(name: "Manufactor"),
                          ServiceCategory(name: "Customer",
                                       deletedAt: .now)])
        }
        
        static var group: ServiceCategory {
            .init(name: "Test")
        }
    }
}
