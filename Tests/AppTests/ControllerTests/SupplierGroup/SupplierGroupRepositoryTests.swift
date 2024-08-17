//
//  SupplierGroupRepositoryTests.swift
//  
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver

@testable import App

final class SupplierGroupRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    var contactGroupRepository: SupplierGroupRepository!
    
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
        
        contactGroupRepository = SupplierGroupRepository()
        
        try await dropCollection(db,
                                 schema: SupplierGroup.schema)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    //MARK: fetchAll
    func testFetchAll_ShouldReturnAllGroup() async throws {
        
        // Given
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2", deletedAt: Date())
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2", deletedAt: Date())
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        
        let result = try await contactGroupRepository.fetchAll(request: .init(sortBy: .name,
                                                                              sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Group2")
    }
    
    func testFetchAll_WithSortByNameAsc_ShouldReturnGroup() async throws {
        
        // Given
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
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
        let group = SupplierGroup(name: "Group")
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
        let group = SupplierGroup(name: "Group")
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
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
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
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
        let request = SupplierGroupRequest.Create(name: "Group")
        
        // When
        let result = try await contactGroupRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertEqual(result.name, "Group")
    }
    
    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group = SupplierGroup(name: "Group")
        try await group.create(on: db)
        
        let request = SupplierGroupRequest.Create(name: "Group")
        
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
        let request = SupplierGroupRequest.Create(name: "Group",
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
        let group = SupplierGroup(name: "Group")
        try await group.create(on: db)
        
        let request = SupplierGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.update(byId: fetchById,
                                                             request: request,
                                                             on: db)
        // Then
        XCTAssertEqual(result.name, "Group2")
    }
    
    func testUpdate_WithDescription_ShouldUpdateGroup() async throws {
        
        // Given
        let group = SupplierGroup(name: "Group")
        try await group.create(on: db)
        
        let request = SupplierGroupRequest.Update(name: nil,
                                                 description: "Des")
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.update(byId: fetchById,
                                                             request: request,
                                                             on: db)
        // Then
        XCTAssertEqual(result.description ?? "", "Des")
    }
    
    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group1 = SupplierGroup(name: "Group1")
        let group2 = SupplierGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        let request = SupplierGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = GeneralRequest.FetchById(id: group1.id!)
        
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
        let request = SupplierGroupRequest.Update(name: "Group2",
                                                 description: "Des")
        
        let fetchById = GeneralRequest.FetchById(id: UUID())
        
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
        let group = SupplierGroup(name: "Group")
        try await group.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactGroupRepository.delete(byId: fetchById,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
}

private extension SupplierGroupRepositoryTests {
    struct Stub {
        static var group40: [SupplierGroup] {
            (0..<40).map { SupplierGroup(name: "Group\($0)") }
        }
    }
}
