//
//  SupplierGroupControllerTests.swift
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

final class SupplierGroupControllerTests: XCTestCase {

    typealias Search = GeneralRequest.Search
    
    var app: Application!
    var db: Database!
    
    lazy var repo = MockSupplierGroupRepositoryProtocol()
    lazy var validator = MockSupplierGroupValidatorProtocol()
    
    var controller: SupplierGroupController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: SupplierGroupMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: SupplierGroup.schema)
        
        //register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /supplier_group
    func testAll_WithNoRequestParam_ShouldReturnEmptyGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.emptyPageGroup)
        
        try app.test(.GET, "supplier_group") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<SupplierGroup>.self)
            XCTAssertEqual(groups.items.count, 0)
        }
    }
        
    func testAll_WithNoRequestParam_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.pageGroup)
    
        try app.test(.GET, "supplier_group") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<SupplierGroup>.self)
            XCTAssertEqual(groups.items.count, 2)
        }
    }
    
    func testAll_WithShowDeleted_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .matching({ $0.showDeleted == true}),
                             on: .any).willReturn(Stub.pageGroupWithDeleted)
        
        try app.test(.GET, "supplier_group?show_deleted=true") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<SupplierGroup>.self)
            XCTAssertEqual(groups.items.count, 3)
        }
    }
    
    // MARK: - Test GET /supplier_group/:id
    func testGetByID_WithID_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willThrow(DefaultError.notFound)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "supplier_group/\(id.uuidString)") { res in
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
        
        try app.test(.GET, "supplier_group/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    // MARK: - Test POST /supplier_group
    func testCreate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let request = SupplierGroupRequest.Create(name: "")
        given(validator).validateCreate(.any).willReturn(request)
                
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "supplier_group",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidName_ShouldReturnGroup() async throws {
        
        // Given
        let request = SupplierGroupRequest.Create(name: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willReturn(Stub.group)
        
        try app.test(.POST, "supplier_group",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testCreate_WithValidNameDescription_ShouldReturnGroup() async throws {
        
        // Given
        let request = SupplierGroupRequest.Create(name: "Test",
                                                 description: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        let stub = SupplierGroup(id: .init(),
                                name: request.name,
                                description: request.description, 
                                createdAt: .now,
                                updatedAt: .now)
        given(repo).create(request: .matching({
            $0.name == request.name &&
            $0.description == request.description
        }),
                           on: .any).willReturn(stub)
        
        try app.test(.POST, "supplier_group",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Test")
            XCTAssertEqual(group.description ?? "", "Test")
        }
    }
    
    // MARK: - Test PUT /supplier_group/:id
    func testUpdate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = SupplierGroupRequest.Update(name: "")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.PUT, "supplier_group/\(id.uuidString)",
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
        let requestUpdate = SupplierGroupRequest.Update(name: "Test")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willReturn(Stub.group)
        
        try app.test(.PUT, "supplier_group/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testUpdate_WithValidNameDescription_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = SupplierGroupRequest.Update(description: "Test")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        let stub = SupplierGroup(id: .init(),
                                name: "Name",
                                description: requestUpdate.description,
                                createdAt: .now,
                                updatedAt: .now)
        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name &&
                                                $0.description == requestUpdate.description }),
                           on: .any).willReturn(stub)
        
        try app.test(.PUT, "supplier_group/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Name")
            XCTAssertEqual(group.description ?? "", "Test")
        }
    }
    
    // MARK: - Test DELETE /supplier_group/:id
    func testDelete_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        given(validator).validateID(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.DELETE, "supplier_group/\(id.uuidString)") { res in
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
        
        try app.test(.DELETE, "supplier_group/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testDelete_WithValidGroup_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let reqId = GeneralRequest.FetchById(id: id)
        given(validator).validateID(.any).willReturn(reqId)
        
        let stub = SupplierGroup(id: .init(),
                                name: "Name",
                                description: "Test",
                                createdAt: .now,
                                updatedAt: .now,
                                deletedAt: .now)
        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           on: .any).willReturn(stub)
        
        try app.test(.DELETE, "supplier_group/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(SupplierGroup.self)
            XCTAssertEqual(group.name, "Name")
            XCTAssertEqual(group.description ?? "", "Test")
            XCTAssertNotNil(group.deletedAt)
        }
    }
    
    // MARK: - Test GET /supplier_group/search
    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
        
        // Given
        let query = Search(query: "")
        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.GET, "supplier_group/search") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSearch_WithMore200CharQuery_ShouldReturnBadRequest() async throws {
        
        // Given
        let query = Search(query: String(repeating: "A", count: 210))
        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
        
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.GET, "supplier_group/search?query=\(query.query)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSearch_WithValidQuery_ShouldReturnEmptyGroups() async throws {
        
        // Given
        let query = Search(query: "Test")
        given(validator).validateSearchQuery(.any).willReturn(query)
        
        let stub = PaginatedResponse<SupplierGroup>(page: 1, perPage: 20, total: 0, items: [])
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willReturn(stub)
        
        try app.test(.GET, "supplier_group/search?query=Test") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<SupplierGroup>.self)
            XCTAssertEqual(groups.total, 0)
        }
    }
    
    func testSearch_WithValidQuery_ShouldReturnGroups() async throws {
        
        // Given
        let query = Search(query: "Test")
        given(validator).validateSearchQuery(.any).willReturn(query)
        
        let stub = PaginatedResponse<SupplierGroup>(page: 1, perPage: 20, total: 2,
                                                   items: [SupplierGroup(name: "Test 1"),
                                                           SupplierGroup(name: "Test 2")])
        given(repo).searchByName(request: .matching({ $0.query == query.query }),
                                 on: .any).willReturn(stub)
        
        try app.test(.GET, "supplier_group/search?query=Test") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<SupplierGroup>.self)
            XCTAssertEqual(groups.total, 2)
        }
    }
    
}

extension SupplierGroupControllerTests {
    struct Stub {
        
        static var emptyPageGroup: PaginatedResponse<SupplierGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 0,
                  items: [])
        }
        
        static var pageGroup: PaginatedResponse<SupplierGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 2,
                  items: [SupplierGroup(name: "Supplier"),
                          SupplierGroup(name: "Manufactor")])
        }
        
        static var pageGroupWithDeleted: PaginatedResponse<SupplierGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 3,
                  items: [SupplierGroup(name: "Supplier"),
                          SupplierGroup(name: "Manufactor"),
                          SupplierGroup(name: "Customer",
                                       deletedAt: .now)])
        }
        
        static var group: SupplierGroup {
            .init(name: "Test")
        }
    }
}
