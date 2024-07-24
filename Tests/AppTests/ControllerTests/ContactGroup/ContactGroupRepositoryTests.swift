//
//  ContactGroupRepositoryTests.swift
//  
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver

@testable import App

final class ContactGroupRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    var contactGroupRepository: ContactGroupRepository!
    
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
        
        contactGroupRepository = ContactGroupRepository()
        
        try await dropCollection(db,
                                 schema: ContactGroup.schema)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    //MARK: fetchAll
    func testFetchAll_ShouldReturnAllGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2", deletedAt: Date())
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Group1")
    }
    
    func testFetchAll_WithShowDeleted_ShouldDeletedGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2", deletedAt: Date())
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(showDeleted: true),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    //perPage min at 20
    func testFetchAll_WithPagination_ShouldReturnGroup() async throws {
        
        // Given
        let groups = Stub.group40
        await createGroups(groups: groups,
                           db: db)
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(page: 2,
                                                                              perPage: 25),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 15)
    }
    
    func testFetchAll_WithSortByNameDesc_ShouldReturnGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Group2")
    }
    
    func testFetchAll_WithSortByNameAsc_ShouldReturnGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Group1")
    }
    
    func testFetchAll_WithSortByCreateAtDesc_ShouldReturnGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Group1")
    }
    
    func testFetchAll_WithSortByCreateAtAsc_ShouldReturnGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Group1")
    }
    
    //MARK: fetchById
    func testFetchById_ShouldReturnGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchById(request: .init(id: group.id!),
                                                                on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Group")
    }
    
    //MARK: fetchByName
    func testFindFirstByName_ShouldReturnGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchByName(request: .init(name: "Group"),
                                                                  on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Group")
    }
    
    //MARK: searchByName
    func testSearchByName_WithExistChar_ShouldReturnGroups() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.searchByName(request: .init(query: "Gr"),
                                                                   on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    func testSearchByName_WithNotExistChar_ShouldNotFoundAnyGroup() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupRepository.searchByName(request: .init(query: "X"),
                                                                   on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 0)
    }
    
    //MARK: create
    func testCreate_ShouldCreateGroup() async throws {
        
        // Given
        let request = ContactGroupRequest.Create(name: "Group")
        
        // When
        let result = try await contactGroupRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertEqual(result.name, "Group")
    }
    
    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        let request = ContactGroupRequest.Create(name: "Group")
        
        // When
        do {
            _ = try await contactGroupRepository.create(request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testCreate_WithNameAndDescription_ShouldCreateGroup() async throws {
        
        // Given
        let request = ContactGroupRequest.Create(name: "Group",
                                                 description: "Des")
        
        // When
        let result = try await contactGroupRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertEqual(result.name, "Group")
        XCTAssertEqual(result.description ?? "", "Des")
    }
    
    //MARK: update
    func testUpdate_WithNameAndDescription_ShouldUpdateGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        let request = ContactGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = ContactGroupRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.update(byId: fetchById,
                                                             request: request,
                                                             on: db)
        // Then
        XCTAssertEqual(result.name, "Group2")
    }
    
    func testUpdate_WithDescription_ShouldUpdateGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        let request = ContactGroupRequest.Update(name: nil,
                                                 description: "Des")
        
        let fetchById = ContactGroupRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.update(byId: fetchById,
                                                             request: request,
                                                             on: db)
        // Then
        XCTAssertEqual(result.description ?? "", "Des")
    }
    
    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        let request = ContactGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = ContactGroupRequest.FetchById(id: group1.id!)
        
        // When
        do {
            _ = try await contactGroupRepository.update(byId: fetchById,
                                                        request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testUpdate_WithNotFoundId_ShouldThrowError() async throws {
        
        // Given
        let request = ContactGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = ContactGroupRequest.FetchById(id: UUID())
        
        // When
        do {
            _ = try await contactGroupRepository.update(byId: fetchById,
                                                        request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: delete
    func testDelete_ShouldDeleteGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        let fetchById = ContactGroupRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.delete(byId: fetchById,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
}

private extension ContactGroupRepositoryTests {
    struct Stub {
        static var group40: [ContactGroup] {
            (0..<40).map { ContactGroup(name: "Group\($0)") }
        }
    }
}

/*
 @Mockable
 protocol ContactGroupRepositoryProtocol {

     func fetchAll(
         request: ContactGroupRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<ContactGroup>
     
     func fetchById(
         request: ContactGroupRequest.FetchById,
         on db: Database
     ) async throws -> ContactGroup?
     
     func fetchByName(
         request: ContactGroupRequest.FetchByName,
         on db: Database
     ) async throws -> ContactGroup?
     
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

 class ContactGroupRepository: ContactGroupRepositoryProtocol {
         
     func fetchAll(
         request: ContactGroupRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<ContactGroup> {
         let query = ContactGroup.query(on: db)
         
         if request.showDeleted {
             query.withDeleted()
         } else {
             query.filter(\.$deletedAt == nil)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(
             query: query,
             sortBy: request.sortBy,
             sortOrder: request.sortOrder,
             page: request.page,
             perPage: request.perPage
         )
         
         let response = PaginatedResponse(
             page: request.page,
             perPage: request.perPage,
             total: total,
             items: items
         )
         
         return response
     }
     
     func fetchById(
         request: ContactGroupRequest.FetchById,
         on db: Database
     ) async throws -> ContactGroup? {
         return try await ContactGroup.query(on: db).filter(\.$id == request.id).first()
     }
     
     func fetchByName(
         request: ContactGroupRequest.FetchByName,
         on db: Database
     ) async throws -> ContactGroup? {
         return try await ContactGroup.query(on: db).filter(\.$name == request.name).first()
     }
     
     func searchByName(
         request: ContactGroupRequest.Search,
         on db: Database
     ) async throws -> PaginatedResponse<ContactGroup> {
         let regexPattern = "(?i)\(request.query)"
         let query = ContactGroup.query(on: db).filter(\.$name =~ regexPattern)
         
         let total = try await query.count()
         let items = try await sortQuery(
             query: query,
             sortBy: request.sortBy,
             sortOrder: request.sortOrder,
             page: request.page,
             perPage: request.perPage
         )
         
         let response = PaginatedResponse(
             page: request.page,
             perPage: request.perPage,
             total: total,
             items: items
         )
         
         return response
     }
     
     func create(
         request: ContactGroupRequest.Create,
         on db: Database
     ) async throws -> ContactGroup {
         // prevent duplicate name
         if let _ = try await fetchByName(request: .init(name: request.name),
                                          on: db) {
             throw CommonError.duplicateName
         }
         
         let group = ContactGroup(name: request.name,
                                  description: request.description)
         try await group.save(on: db)
         return group
     }
     
     func update(
         byId: ContactGroupRequest.FetchById,
         request: ContactGroupRequest.Update,
         on db: Database
     ) async throws -> ContactGroup {
         guard
             var group = try await fetchById(request: .init(id: byId.id),
                                            on: db)
         else { throw Abort(.notFound) }
       
         if let name = request.name {
             // prevent duplicate name
             if let _ = try await fetchByName(request: .init(name: name),
                                              on: db) {
                 throw CommonError.duplicateName
             }
             
             group.name = name
         }
         
         if let description = request.description {
             group.description = description
         }
         
         try await group.save(on: db)
         return group
     }
     
     func delete(
         byId: ContactGroupRequest.FetchById,
         on db: Database
     ) async throws -> ContactGroup {
         guard
             var group = try await fetchById(request: .init(id: byId.id),
                                            on: db)
         else { throw Abort(.notFound) }
         
         try await group.delete(on: db)
         return group
     }
     
 }

 private extension ContactGroupRepository {
     func sortQuery(
         query: QueryBuilder<ContactGroup>,
         sortBy: ContactGroupRequest.SortBy,
         sortOrder: ContactGroupRequest.SortOrder,
         page: Int,
         perPage: Int
     ) async throws -> [ContactGroup] {
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         }
     }
 }

 */
