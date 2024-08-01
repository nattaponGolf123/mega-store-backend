//
//  ContactControllerTests.swift
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

final class ContactControllerTests: XCTestCase {

    var app: Application!
    var db: Database!
    
    lazy var repo = MockContactRepositoryProtocol()
    lazy var validator = MockContactValidatorProtocol()
    
    var controller: ContactController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ContactMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: Contact.schema)
        
        //register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
//    // MARK: - Tests GET /contact_groups
//    func testAll_WithNoRequestParam_ShouldReturnEmptyGroups() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .any,
//                             on: .any).willReturn(Stub.emptyPageGroup)
//        
//        try app.test(.GET, "contact_groups") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<Contact>.self)
//            XCTAssertEqual(groups.items.count, 0)
//        }
//    }
//        
//    func testAll_WithNoRequestParam_ShouldReturnAllGroups() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .any,
//                             on: .any).willReturn(Stub.pageGroup)
//    
//        try app.test(.GET, "contact_groups") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<Contact>.self)
//            XCTAssertEqual(groups.items.count, 2)
//        }
//    }
//    
//    func testAll_WithShowDeleted_ShouldReturnAllGroups() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .matching({ $0.showDeleted == true}),
//                             on: .any).willReturn(Stub.pageGroupWithDeleted)
//        
//        try app.test(.GET, "contact_groups?show_deleted=true") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<Contact>.self)
//            XCTAssertEqual(groups.items.count, 3)
//        }
//    }
//    
//    // MARK: - Test GET /contact_groups/:id
//    func testGetByID_WithID_ShouldReturnNotFound() async throws {
//        
//        // Given
//        let id = UUID()
//        let request = ContactRequest.FetchById(id: id)
//        given(repo).fetchById(request: .matching({ $0.id == id}),
//                              on: .any).willThrow(DefaultError.notFound)
//        given(validator).validateID(.any).willReturn(request)
//        
//        try app.test(.GET, "contact_groups/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .notFound)
//        }
//        
//    }
//    
//    func testGetByID_WithMatchID_ShouldReturnGroup() async throws {
//        
//        // Given
//        let id = UUID()
//        let request = ContactRequest.FetchById(id: id)
//        given(repo).fetchById(request: .matching({ $0.id == id}),
//                              on: .any).willReturn(Stub.group)
//        given(validator).validateID(.any).willReturn(request)
//        
//        try app.test(.GET, "contact_groups/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    // MARK: - Test POST /contact_groups
//    func testCreate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let request = ContactRequest.Create(name: "")
//        given(validator).validateCreate(.any).willReturn(request)
//                
//        given(repo).create(request: .matching({ $0.name == request.name }),
//                           on: .any).willThrow(DefaultError.insertFailed)
//        
//        try app.test(.POST, "contact_groups",
//                     beforeRequest: { req in
//                        try req.content.encode(request)
//                     }) { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testCreate_WithValidName_ShouldReturnGroup() async throws {
//        
//        // Given
//        let request = ContactRequest.Create(name: "Test")
//        given(validator).validateCreate(.any).willReturn(request)
//        
//        given(repo).create(request: .matching({ $0.name == request.name }),
//                           on: .any).willReturn(Stub.group)
//        
//        try app.test(.POST, "contact_groups",
//                     beforeRequest: { req in
//                        try req.content.encode(request)
//                     }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    func testCreate_WithValidNameDescription_ShouldReturnGroup() async throws {
//        
//        // Given
//        let request = ContactRequest.Create(name: "Test",
//                                                 description: "Test")
//        given(validator).validateCreate(.any).willReturn(request)
//        
//        let stub = Contact(id: .init(),
//                                name: request.name,
//                                description: request.description, 
//                                createdAt: .now,
//                                updatedAt: .now)
//        given(repo).create(request: .matching({
//            $0.name == request.name &&
//            $0.description == request.description
//        }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.POST, "contact_groups",
//                     beforeRequest: { req in
//                        try req.content.encode(request)
//                     }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Test")
//            XCTAssertEqual(group.description ?? "", "Test")
//        }
//    }
//    
//    // MARK: - Test PUT /contact_groups/:id
//    func testUpdate_WithInvalidGroup_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        let requestId = ContactRequest.FetchById(id: id)
//        let requestUpdate = ContactRequest.Update(name: "")
//        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
//        
//        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           request: .matching({ $0.name == requestUpdate.name }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.PUT, "contact_groups/\(id.uuidString)",
//                     beforeRequest: { req in
//                        try req.content.encode(requestUpdate)
//                     }) { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testUpdate_WithValidName_ShouldReturnGroup() async throws {
//        
//        // Given
//        let id = UUID()
//        let requestId = ContactRequest.FetchById(id: id)
//        let requestUpdate = ContactRequest.Update(name: "Test")
//        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
//        
//        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           request: .matching({ $0.name == requestUpdate.name }),
//                           on: .any).willReturn(Stub.group)
//        
//        try app.test(.PUT, "contact_groups/\(id.uuidString)",
//                     beforeRequest: { req in
//                        try req.content.encode(requestUpdate)
//                     }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    func testUpdate_WithValidNameDescription_ShouldReturnGroup() async throws {
//        
//        // Given
//        let id = UUID()
//        let requestId = ContactRequest.FetchById(id: id)
//        let requestUpdate = ContactRequest.Update(description: "Test")
//        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
//        
//        let stub = Contact(id: .init(),
//                                name: "Name",
//                                description: requestUpdate.description,
//                                createdAt: .now,
//                                updatedAt: .now)
//        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           request: .matching({ $0.name == requestUpdate.name &&
//                                                $0.description == requestUpdate.description }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.PUT, "contact_groups/\(id.uuidString)",
//                     beforeRequest: { req in
//                        try req.content.encode(requestUpdate)
//                     }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Name")
//            XCTAssertEqual(group.description ?? "", "Test")
//        }
//    }
//    
//    // MARK: - Test DELETE /contact_groups/:id
//    func testDelete_WithInvalidGroup_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        given(validator).validateID(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.DELETE, "contact_groups/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testDelete_WithNotExistId_ShouldReturnNotFound() async throws {
//        
//        // Given
//        let id = UUID()
//        let reqId = ContactRequest.FetchById(id: id)
//        given(validator).validateID(.any).willReturn(reqId)
//        
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willThrow(DefaultError.notFound)
//        
//        try app.test(.DELETE, "contact_groups/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .notFound)
//        }
//    }
//    
//    func testDelete_WithValidGroup_ShouldReturnGroup() async throws {
//        
//        // Given
//        let id = UUID()
//        let reqId = ContactRequest.FetchById(id: id)
//        given(validator).validateID(.any).willReturn(reqId)
//        
//        let stub = Contact(id: .init(),
//                                name: "Name",
//                                description: "Test",
//                                createdAt: .now,
//                                updatedAt: .now,
//                                deletedAt: .now)
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.DELETE, "contact_groups/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(Contact.self)
//            XCTAssertEqual(group.name, "Name")
//            XCTAssertEqual(group.description ?? "", "Test")
//            XCTAssertNotNil(group.deletedAt)
//        }
//    }
//    
//    // MARK: - Test GET /contact_groups/search
//    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let query = ContactRequest.Search(query: "")
//        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).searchByName(request: .matching({ $0.query == query.query }),
//                                 on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.GET, "contact_groups/search") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testSearch_WithMore200CharQuery_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let query = ContactRequest.Search(query: String(repeating: "A", count: 210))
//        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).searchByName(request: .matching({ $0.query == query.query }),
//                                 on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.GET, "contact_groups/search?query=\(query.query)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testSearch_WithValidQuery_ShouldReturnEmptyGroups() async throws {
//        
//        // Given
//        let query = ContactRequest.Search(query: "Test")
//        given(validator).validateSearchQuery(.any).willReturn(query)
//        
//        let stub = PaginatedResponse<Contact>(page: 1, perPage: 20, total: 0, items: [])
//        given(repo).searchByName(request: .matching({ $0.query == query.query }),
//                                 on: .any).willReturn(stub)
//        
//        try app.test(.GET, "contact_groups/search?query=Test") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<Contact>.self)
//            XCTAssertEqual(groups.total, 0)
//        }
//    }
//    
//    func testSearch_WithValidQuery_ShouldReturnGroups() async throws {
//        
//        // Given
//        let query = ContactRequest.Search(query: "Test")
//        given(validator).validateSearchQuery(.any).willReturn(query)
//        
//        let stub = PaginatedResponse<Contact>(page: 1, perPage: 20, total: 2,
//                                                   items: [Contact(name: "Test 1"),
//                                                           Contact(name: "Test 2")])
//        given(repo).searchByName(request: .matching({ $0.query == query.query }),
//                                 on: .any).willReturn(stub)
//        
//        try app.test(.GET, "contact_groups/search?query=Test") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<Contact>.self)
//            XCTAssertEqual(groups.total, 2)
//        }
//    }
    
}

extension ContactControllerTests {
//    struct Stub {
//        
//        static var emptyPageGroup: PaginatedResponse<Contact> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 0,
//                  items: [])
//        }
//        
//        static var pageGroup: PaginatedResponse<Contact> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 2,
//                  items: [Contact(name: "Supplier"),
//                          Contact(name: "Manufactor")])
//        }
//        
//        static var pageGroupWithDeleted: PaginatedResponse<Contact> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 3,
//                  items: [Contact(name: "Supplier"),
//                          Contact(name: "Manufactor"),
//                          Contact(name: "Customer",
//                                       deletedAt: .now)])
//        }
//        
//        static var group: Contact {
//            .init(name: "Test")
//        }
//    }
}

/*
 import Foundation
 import Fluent
 import Vapor

 class ContactController: RouteCollection {
     
     private(set) var repository: ContactRepositoryProtocol
     private(set) var validator: ContactValidatorProtocol
     
     init(repository: ContactRepositoryProtocol = ContactRepository(),
          validator: ContactValidatorProtocol = ContactValidator()) {
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
     func all(req: Request) async throws -> PaginatedResponse<Contact> {
         let content = try req.query.decode(ContactRequest.FetchAll.self)

         return try await repository.fetchAll(request: content,
                                              on: req.db)
     }
     
     // POST /contact_groups
     func create(req: Request) async throws -> Contact {
         let content = try validator.validateCreate(req)
         
         return try await repository.create(request: content,
                                            on: req.db)
     }
     
     // GET /contact_groups/:id
     func getByID(req: Request) async throws -> Contact {
         let content = try validator.validateID(req)
         
         return try await repository.fetchById(request: content,
                                               on: req.db)
     }
     
     // PUT /contact_groups/:id
     func update(req: Request) async throws -> Contact {
         let (id, content) = try validator.validateUpdate(req)
         
         return try await repository.update(byId: id,
                                            request: content,
                                            on: req.db)
     }

     // DELETE /contact_groups/:id
     func delete(req: Request) async throws -> Contact {
         let id = try validator.validateID(req)
         
         return try await repository.delete(byId: id,
                                            on: req.db)
     }
     
     // GET /contact_groups/search?name=xxx&page=1&per_page=10
     func search(req: Request) async throws -> PaginatedResponse<Contact> {
         
         let content = try validator.validateSearchQuery(req)
         
         return try await repository.searchByName(request: content,
                                                  on: req.db)
     }
 }

 */

/*
 protocol ContactRepositoryProtocol {

     func fetchAll(
         request: ContactRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func fetchById(
         request: ContactRequest.FetchById,
         on db: Database
     ) async throws -> Contact
     
     func fetchByName(
         request: ContactRequest.FetchByName,
         on db: Database
     ) async throws -> Contact
     
     func searchByName(
         request: ContactRequest.Search,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func create(
         request: ContactRequest.Create,
         on db: Database
     ) async throws -> Contact
     
     func update(
         byId: ContactRequest.FetchById,
         request: ContactRequest.Update,
         on db: Database
     ) async throws -> Contact
     
     func delete(
         byId: ContactRequest.FetchById,
         on db: Database
     ) async throws -> Contact
 }

 */

/*
 
 @Mockable
 protocol ContactValidatorProtocol {
     func validateCreate(_ req: Request) throws -> ContactRequest.Create
     func validateUpdate(_ req: Request) throws -> (id: ContactRequest.FetchById, content: ContactRequest.Update)
     func validateID(_ req: Request) throws -> ContactRequest.FetchById
     func validateSearchQuery(_ req: Request) throws -> ContactRequest.Search
 }

 class ContactValidator: ContactValidatorProtocol {
     typealias CreateContent = ContactRequest.Create
     typealias UpdateContent = (id: ContactRequest.FetchById, content: ContactRequest.Update)

     func validateCreate(_ req: Request) throws -> CreateContent {
         try CreateContent.validate(content: req)
         
         return try req.content.decode(CreateContent.self)
     }

     func validateUpdate(_ req: Request) throws -> UpdateContent {
         try ContactRequest.Update.validate(content: req)
         
         let id = try req.parameters.require("id", as: UUID.self)
         let fetchById = ContactRequest.FetchById(id: id)
         let content = try req.content.decode(ContactRequest.Update.self)
         
         return (fetchById, content)
     }

     func validateID(_ req: Request) throws -> ContactRequest.FetchById {
         do {
             return try req.query.decode(ContactRequest.FetchById.self)
         } catch {
             throw DefaultError.invalidInput
         }
     }

     func validateSearchQuery(_ req: Request) throws -> ContactRequest.Search {
         do {
             let content = try req.query.decode(ContactRequest.Search.self)
             
             guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
             
             return content
         }
         catch {
             throw DefaultError.invalidInput
         }
     }
 }

 */
