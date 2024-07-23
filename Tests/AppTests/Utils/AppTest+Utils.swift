//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/7/2567 BE.
//

import Foundation
import XCTest
import Fluent
import Vapor
import FluentMongoDriver

extension XCTestCase {
    
    func configure(_ app: Application,
                   dbHost: String,
                   migration: AsyncMigration) throws {
        // Database configuration
        app.databases.use(try .mongo(connectionString: dbHost),
                          as: .mongo)
        
        // Migrations
        app.migrations.add(migration)
        
        try app.autoMigrate().wait()                
    }
    
    // Assuming `groups` is an array of ContactGroup objects
    func createGroups(groups: [any Model], db: Database) async {
        await withTaskGroup(of: Result<Void, Error>.self) { taskGroup in
            for group in groups {
                taskGroup.addTask {
                    do {
                        try await group.create(on: db)
                        return .success(())
                    } catch {
                        return .failure(error)
                    }
                }
            }
            
            for await result in taskGroup {
                switch result {
                case .success:
                    // Handle success if needed
                    break
                case .failure(let error):
                    // Handle error if needed
                    print("Failed to create group: \(error)")
                }
            }
        }
    }
    
    func dropCollection(_ db: Database, schema: String) async throws {
        
        // Ensure the database is of type FluentMongoDriver.MongoDatabaseRepresentable
        guard let mongoDB = db as? FluentMongoDriver.MongoDatabaseRepresentable else { return }
        
        // Drop the collection
        let _ = mongoDB.raw[schema].drop()
    }
    
}
