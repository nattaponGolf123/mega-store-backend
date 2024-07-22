//
//  ContactGroupQueryingTests.swift
//  
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver

@testable import App

final class ContactGroupQueryingTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    var contactGroupQuerying: ContactGroupQuerying!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        try configure(app)
        
        db = app.db
        contactGroupQuerying = ContactGroupQuerying()
        
        try await cleanDatabase(db)
    }
    
    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    func testFetchAll() async throws {
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2", deletedAt: Date())
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupQuerying.fetchAll(on: db, showDeleted: false, page: 1, perPage: 10, sortBy: .name, sortOrder: .asc)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Group1")
    }
    
    func testFindById() async throws {
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupQuerying.findById(id: group.id!, on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Group")
    }
    
    func testFindByName() async throws {
        // Given
        let group = ContactGroup(name: "Group")
        try await group.create(on: db)
        
        // When
        let result = try await contactGroupQuerying.findByName(name: "Group", on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Group")
    }
    
    func testSearchByName() async throws {
        // Given
        let group1 = ContactGroup(name: "Group1")
        let group2 = ContactGroup(name: "Group2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactGroupQuerying.searchByName(name: "Group", on: db, page: 1, perPage: 10, sortBy: .name, sortOrder: .asc)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    private func configure(_ app: Application) throws {
        // Database configuration
        let testDB = "mongodb://localhost:27017/testdb"
        //let url = try dbHostURL(app)
        app.databases.use(try .mongo(connectionString: testDB),
                          as: .mongo)
        
        // Migrations
        let migration = ContactGroupMigration()
        app.migrations.add(migration)
        
        try app.autoMigrate().wait()
    }
    
    private func cleanDatabase(_ db: Database) async throws {
        try await contactGroupQuerying.deleteAll(on: db)
    }
}
