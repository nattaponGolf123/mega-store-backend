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
                      dbHost: dbHost)
        
        db = app.db
        contactGroupRepository = ContactGroupRepository()
        
        try await dropCollection(db)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    func testA() async throws  {
        
    }

}

extension ContactGroupControllerTests {
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
