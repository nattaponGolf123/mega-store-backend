//
//  ContactGroupControllerTests.swift
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

final class ContactGroupControllerTests: XCTestCase {

    var app: Application!
    var db: Database!
    
    lazy var repo = MockContactGroupRepositoryProtocol()
    lazy var validator = MockContactGroupValidatorProtocol()
    
    var controller: ContactGroupController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ContactGroupMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: ContactGroup.schema)
        
        //register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /contact_groups
    func testAll_WithNoRequestParam_ShouldReturnEmptyGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.emptyPageGroup)
        
        try app.test(.GET, "contact_groups") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ContactGroup>.self)
            XCTAssertEqual(groups.items.count, 0)
        }
    }
        
    func testAll_WithNoRequestParam_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .any,
                             on: .any).willReturn(Stub.pageGroup)
    
        try app.test(.GET, "contact_groups") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ContactGroup>.self)
            XCTAssertEqual(groups.items.count, 2)
        }
    }
    
    func testAll_WithShowDeleted_ShouldReturnAllGroups() async throws {
        
        // Given
        given(repo).fetchAll(request: .matching({ $0.showDeleted == true}),
                             on: .any).willReturn(Stub.pageGroupWithDeleted)
        
        try app.test(.GET, "contact_groups?show_deleted=true") { res in
            XCTAssertEqual(res.status, .ok)
            let groups = try res.content.decode(PaginatedResponse<ContactGroup>.self)
            XCTAssertEqual(groups.items.count, 3)
        }
    }
    
    // MARK: - Test GET /contact_groups/:id
    func testGetByID_WithID_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let request = ContactGroupRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willThrow(DefaultError.notFound)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "contact_groups/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
        
    }
    
    func testGetByID_WithMatchID_ShouldReturnGroup() async throws {
        
        // Given
        let id = UUID()
        let request = ContactGroupRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willReturn(Stub.group)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "contact_groups/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ContactGroup.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    // MARK: - Test POST /contact_groups
    func testCreate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
        
        // Given
        let request = ContactGroupRequest.Create(name: "")
        given(validator).validateCreate(.any).willReturn(request)
                
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "contact_groups",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidName_ShouldReturnGroup() async throws {
        
        // Given
        let request = ContactGroupRequest.Create(name: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willReturn(Stub.group)
        
        try app.test(.POST, "contact_groups",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ContactGroup.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testCreate_WithValidNameDescription_ShouldReturnGroup() async throws {
        
        // Given
        let request = ContactGroupRequest.Create(name: "Test",
                                                 description: "Test")
        given(validator).validateCreate(.any).willReturn(request)
        
        let stub = ContactGroup(id: .init(),
                                name: request.name,
                                description: request.description, 
                                createdAt: .now,
                                updatedAt: .now)
        given(repo).create(request: .matching({
            $0.name == request.name &&
            $0.description == request.description
        }),
                           on: .any).willReturn(stub)
        
        try app.test(.POST, "contact_groups",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(ContactGroup.self)
            XCTAssertEqual(group.name, "Test")
            XCTAssertEqual(group.description ?? "", "Test")
        }
    }
}

extension ContactGroupControllerTests {
    struct Stub {
        
        static var emptyPageGroup: PaginatedResponse<ContactGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 0,
                  items: [])
        }
        
        static var pageGroup: PaginatedResponse<ContactGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 2,
                  items: [ContactGroup(name: "Supplier"),
                          ContactGroup(name: "Manufactor")])
        }
        
        static var pageGroupWithDeleted: PaginatedResponse<ContactGroup> {
            .init(page: 1,
                  perPage: 10,
                  total: 3,
                  items: [ContactGroup(name: "Supplier"),
                          ContactGroup(name: "Manufactor"),
                          ContactGroup(name: "Customer",
                                       deletedAt: .now)])
        }
        
        static var group: ContactGroup {
            .init(name: "Test")
        }
    }
}

/*
 import Foundation
 import Fluent
 import Vapor

 class ContactGroupController: RouteCollection {
     
     private(set) var repository: ContactGroupRepositoryProtocol
     private(set) var validator: ContactGroupValidatorProtocol
     
     init(repository: ContactGroupRepositoryProtocol = ContactGroupRepository(),
          validator: ContactGroupValidatorProtocol = ContactGroupValidator()) {
         self.repository = repository
         self.validator = validator
     }
     
     func boot(routes: RoutesBuilder) throws {
         
         let groups = routes.grouped("contact_groups")
         groups.get(use: all)
         groups.post(use: create)
         
         groups.group(":id") { withID in
             withID.get(use: getByID)
             withID.put(use: update)
             withID.delete(use: delete)
         }
         
         groups.group("search") { _search in
             _search.get(use: search)
         }
     }
     
     // GET /contact_groups?show_deleted=true&page=1&per_page=10
     func all(req: Request) async throws -> PaginatedResponse<ContactGroup> {
         let content = try req.query.decode(ContactGroupRequest.FetchAll.self)

         return try await repository.fetchAll(request: content,
                                              on: req.db)
     }
     
     // POST /contact_groups
     func create(req: Request) async throws -> ContactGroup {
         let content = try validator.validateCreate(req)
         
         return try await repository.create(request: content,
                                            on: req.db)
     }
     
     // GET /contact_groups/:id
     func getByID(req: Request) async throws -> ContactGroup {
         let content = try validator.validateID(req)
         
         return try await repository.fetchById(request: content,
                                               on: req.db)
     }
     
     // PUT /contact_groups/:id
     func update(req: Request) async throws -> ContactGroup {
         let (id, content) = try validator.validateUpdate(req)
         
         return try await repository.update(byId: id,
                                            request: content,
                                            on: req.db)
     }

     // DELETE /contact_groups/:id
     func delete(req: Request) async throws -> ContactGroup {
         let id = try validator.validateID(req)
         
         return try await repository.delete(byId: id,
                                            on: req.db)
     }
     
     // GET /contact_groups/search?name=xxx&page=1&per_page=10
     func search(req: Request) async throws -> PaginatedResponse<ContactGroup> {
         
         let content = try validator.validateSearchQuery(req)
         
         return try await repository.searchByName(request: content,
                                                  on: req.db)
     }
 }

 */

/*
 protocol ContactGroupRepositoryProtocol {

     func fetchAll(
         request: ContactGroupRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<ContactGroup>
     
     func fetchById(
         request: ContactGroupRequest.FetchById,
         on db: Database
     ) async throws -> ContactGroup
     
     func fetchByName(
         request: ContactGroupRequest.FetchByName,
         on db: Database
     ) async throws -> ContactGroup
     
     func searchByName(
         request: ContactGroupRequest.Search,
         on db: Database
     ) async throws -> PaginatedResponse<ContactGroup>
     
     func create(
         request: ContactGroupRequest.Create,
         on db: Database
     ) async throws -> ContactGroup
     
     func update(
         byId: ContactGroupRequest.FetchById,
         request: ContactGroupRequest.Update,
         on db: Database
     ) async throws -> ContactGroup
     
     func delete(
         byId: ContactGroupRequest.FetchById,
         on db: Database
     ) async throws -> ContactGroup
 }

 */
