//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

class MyBusineseSchema {
    static var schema: String { MyBusinese.schema }
    
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
            .field("website", .string, .required)
            .field("business_address", .json, .required)
            .field("shipping_address", .json, .required)
            .field("logo", .string)
            .field("stamp_logo", .string)
            .field("authorized_sign_signature", .string)
            .field("note", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)      
    }
    
}
