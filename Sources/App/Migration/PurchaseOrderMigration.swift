//
//  ContactMigration 2.swift
//  poc-swift-vapor-rest
//
//  Created by IntrodexMac on 20/9/2567 BE.
//


import Foundation
import Fluent
import Vapor

struct PurchaseOrderMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await PurchaseOrderSchema.createBuilder(database: database).create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PurchaseOrderSchema.schema).delete()
    }
}
