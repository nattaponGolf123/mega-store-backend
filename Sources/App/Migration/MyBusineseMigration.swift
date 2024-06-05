//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct MyBusineseMigration: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await MyBusineseSchema.createBuilder(database: database).create()
        
        // new mocks
        try await MyBusinese.Stub.myCompany.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(MyBusineseSchema.schema).delete()
    }
}

/*
 struct CustomerGroupMigration: AsyncMigration {
     func prepare(on database: Database) async throws {
         try await CustomerGroupSchema.createBuilder(database: database).create()
         
         // new mocks
         try await CustomerGroup.Stub.retail.save(on: database)
     }
     func revert(on database: Database) async throws {
         try await database.schema(CustomerGroupSchema.schema).delete()
     }
 }

 */
