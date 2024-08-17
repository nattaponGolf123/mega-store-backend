import Foundation
import Vapor
import Fluent

struct SupplierGroupSchema {
    static var schema: String { SupplierGroup.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("description", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}
