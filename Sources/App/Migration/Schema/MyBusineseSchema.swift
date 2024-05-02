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
            .field("contact_information", .json, .required)
            .field("tax_number", .string, .required)
            .unique(on: "tax_number")
            .field("legal_status", .string, .required)
            .field("website", .string, .required)
            .field("business_address", .json, .required)            
            .field("note", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}

/*

class SupplierSchema {
    static var schema: String { Supplier.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("contact_information", .json, .required)
            .field("tax_number", .string, .required)
            .unique(on: "tax_number")
            .field("legal_status", .string, .required)
            .field("website", .string, .required)
            .field("business_address", .json, .required)
            .field("payment_terms_days", .int)
            .field("note", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}


//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

enum BusinessType: String, Codable {
    case limitedCompany
    case individual
}

final class MyBusinese: Model, Content {
    static let schema = "MyBusinese"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "contact_information")
    var contactInformation: ContactInformation

    @Field(key: "tax_number")
    var taxNumber: String

    @Enum(key: "legal_status")
    var legalStatus: BusinessType

    @Field(key: "website")
    var website: String

    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]

    @Field(key: "note")
    var note: String

    @Timestamp(key: "created_at",
               on: .create,
               format: .iso8601)
    var createdAt: Date?

    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil,
         name: String,
         contactInformation: ContactInformation,
         taxNumber: String,
         legalStatus: BusinessType,
         website: String,
         businessAddress: [BusinessAddress],
         note: String) {
        self.id = id ?? UUID()
        self.name = name
        self.contactInformation = contactInformation
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.note = note
    }

    struct ContactInformation: Content {
        var contactPerson: String
        var phoneNumber: String        
        var email: String
        var address: String
    }

    struct BusinessAddress: Content {
        var address: String
        var city: String
        var postalCode: String
        var country: String
        var phoneNumber: String
        var email: String
        var fax: String
    }

}

/*
{
    "id": "SUP12345", // UUID
    "name": "ABC Industries",
    "contact_information": {
        "contact_person": "John Doe",
        "phone_number": "123-456-7890",
        "email": "contact@abcindustries.com",
        "address": "1234 Industrial Way, Business City, BC 56789"
    },
    "tax_number": "123123212123",
    "legal_tatus" : "corporate" , // ["limited company", "individual"]
    "website": "www.abcindustries.com",
    "businese_address": [{
        "address" : "123",
        "city" : "Bangkok",
        "postal_code" : "12022",
        "country" : "Thailand",
        "phone_number" : "123-456-7890"
        "email" : "",
        "fax" : ""
        }],
    
    "payment_terms_days": 30,
    "note": "Reliable supplier with consistent quality and delivery times.",
    "created_at": "2021-03-05T07:00:00Z",
    "updated_at": "2021-03-05T07:00:00Z",
    "deleted_at": null
}
*/

*/
