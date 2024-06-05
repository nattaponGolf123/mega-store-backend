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
            .field("note", .string, .required)      
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)      
    }
    
}

/*
enum BusinessType: String, Codable {
    case companyLimited = "COMPANY_LIMITED"
    case publicCompanyLimited = "PUBLIC_COMPANY_LIMITED"
    case limitedPartnership = "LIMITED_PARTNERSHIP"
    case individual = "INDIVIDUAL"
}

final class MyBusinese: Model, Content {
    static let schema = "MyBusinese"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "vat_registered")
    var vatRegistered: Bool
    
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
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]
    
    @Field(key: "logo")
    var logo: String?
    
    @Field(key: "stamp_logo")
    var stampLogo: String?
    
    @Field(key: "authorized_sign_signature")
    var authorizedSignSignature: String?
    
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
         vatRegistered: Bool,
         contactInformation: ContactInformation,
         taxNumber: String,
         legalStatus: BusinessType,
         website: String,
         businessAddress: [BusinessAddress],
         shippingAddress: [ShippingAddress],
         logo: String?,
         stampLogo: String?,
         authorizedSignSignature: String?,
         note: String) {
        self.id = id ?? UUID()
        self.name = name
        self.vatRegistered = vatRegistered
        self.contactInformation = contactInformation
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.shippingAddress = shippingAddress
        self.logo = logo
        self.stampLogo = stampLogo
        self.authorizedSignSignature = authorizedSignSignature
        self.note = note
    }
    
}

extension MyBusinese {
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String
        let businessAddress: [BusinessAddress]
        let shippingAddress: [ShippingAddress]
        let logo: String?
        let stampLogo: String?
        let authorizedSignSignature: String?
        let note: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("taxNumber", as: String.self,
                            is: .count(13...13))
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?
        let businessAddress: [BusinessAddress]?
        let shippingAddress: [ShippingAddress]?
        let logo: String?
        let stampLogo: String?
        let authorizedSignSignature: String?
        let note: String?
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("taxNumber", as: String.self,
                            is: .count(13...13))
        }
    }
    
}


extension MyBusinese {
    struct Stub {
        static var myCompany: MyBusinese {
            MyBusinese(id: UUID(),
                       name: "ABC Industries",
                       vatRegistered: true,
                       contactInformation: ContactInformation(contactPerson: "John Doe",
                                                              phoneNumber: "123-456-7890",
                                                              email: "abc@email.com"),
                       taxNumber: "123123212123",
                       legalStatus: .companyLimited,
                       website: "www.abcindustries.com",
                       businessAddress: [BusinessAddress(address: "123",
                                                         branch: "123",
                                                         subDistrict: "123",
                                                         city: "Bangkok",
                                                         province: "ddd",
                                                         postalCode: "12022",
                                                         country: "Thailand",
                                                         phoneNumber: "123-456-7890",
                                                         email: "",
                                                         fax: "")],
                       shippingAddress: [ShippingAddress(address: "1234 Industrial Way",
                                               branch: "Business City",
                                               subDistrict: "Business City",
                                               city: "Business City",
                                               province: "BC",
                                               postalCode: "56789")],
                       logo: "https://www.abcindustries.com/logo.png",
                       stampLogo: "https://www.abcindustries.com/stamp.png",
                       authorizedSignSignature: "https://www.abcindustries.com/signature.png",
                       note: "Reliable supplier with consistent quality and delivery times.")
        }
    }
}
*/

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
*/