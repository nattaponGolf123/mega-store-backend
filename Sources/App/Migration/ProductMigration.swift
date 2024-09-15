//
//  File.swift
//  
//
//  Created by IntrodexMac on 15/9/2567 BE.
//

import Foundation
import Fluent
import Vapor

 struct ProductMigration: AsyncMigration {
     func prepare(on database: Database) async throws {
         try await ProductSchema.createBuilder(database: database).create()
        
     }

     func revert(on database: Database) async throws {
         try await database.schema(ProductSchema.schema).delete()
     }
 }
