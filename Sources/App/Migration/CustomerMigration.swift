import Foundation
import Fluent
import Vapor

struct CustomerMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await CustomerSchema.createBuilder(database: database).create()
        
        // new mocks
        try await Customer.Stub.individul.save(on: database)
    }
    func revert(on database: Database) async throws {
        try await database.schema(CustomerSchema.schema).delete()
    }
}