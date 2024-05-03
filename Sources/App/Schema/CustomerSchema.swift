import Foundation
import Vapor
import Fluent

struct CustomerSchema {
    static var schema: String { Customer.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("vat_registered", .bool, .required)
            .field("contact_information", .json, .required)
            .field("tax_number", .string, .required)
            .unique(on: "tax_number")
            .field("legal_status", .string, .required)
            .field("website", .string)
            .field("business_address", .json, .required)
            .field("payment_terms_days", .int)
            .field("note", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)            
    }
    
}
