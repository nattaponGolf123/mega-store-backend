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
    let dbHost: String = "mongodb://localhost:27017/testdb"
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        try configure(app,
                      dbHost: dbHost)
        
        db = app.db
        contactGroupRepository = ContactGroupRepository()
        
        try await dropCollection(db)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
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
    
    func testFetchById_ShouldReturnGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchById(request: .init(id: group.id!),
                                                                on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Group")
    }
    
    func testFindFirstByName_ShouldReturnGroup() async throws {
        
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupRepository.fetchByName(request: .init(name: "Group"),
                                                                  on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Group")
    }
    
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
    
}

private extension ContactGroupRepositoryTests {
    
     func configure(_ app: Application,
                           dbHost: String) throws {
        // Database configuration
        app.databases.use(try .mongo(connectionString: dbHost),
                          as: .mongo)
        
        // Migrations        
        app.migrations.add(ContactGroupMigration())
        
        try app.autoMigrate().wait()
    }
            
    func dropCollection(_ db: Database) async throws {
        
        // Ensure the database is of type FluentMongoDriver.MongoDatabaseRepresentable
        guard let mongoDB = db as? FluentMongoDriver.MongoDatabaseRepresentable else { return }
        
        // Drop the collection
        let _ = mongoDB.raw[ContactGroup.schema].drop()
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
