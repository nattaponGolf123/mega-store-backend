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

@testable import App

final class ContactGroupControllerTests: XCTestCase {

    var app: Application!
    var db: Database!
    lazy var repo = MockContactGroupRepositoryProtocol()
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
    
    func testA() async throws  {
        
    }

}
