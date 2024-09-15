//
//  ProductCategoryMigration.swift
//
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Fluent
import Vapor

 struct ProductCategoryMigration: AsyncMigration {
     func prepare(on database: Database) async throws {
         try await ProductCategorySchema.createBuilder(database: database).create()
     }

     func revert(on database: Database) async throws {
         try await database.schema(ProductCategorySchema.schema).delete()
     }
 }
