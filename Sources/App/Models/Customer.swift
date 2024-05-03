//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class Customer: Model, Content {
    static let schema = "Customers"
    
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
    
    @Field(key: "legal_status")
    var legalStatus: BusinessType
    
    @Field(key: "website")
    var website: String
    
    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int?
    
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
         paymentTermsDays: Int?,
         note: String) {
        self.id = id ?? UUID()
        self.name = name
        self.vatRegistered = vatRegistered
        self.contactInformation = contactInformation
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.paymentTermsDays = paymentTermsDays
        self.note = note
    }
    
}

extension Customer {
    struct Stub {
        
        static var individul: Customer {
            
            let contactInformation = ContactInformation(contactPerson: "John Doe",
                                                        phoneNumber: "1234567890",
                                                        email: "")
            let businessAddress = [BusinessAddress(address: "123/456",
                                                   branch: "",
                                                   subDistrict: "",
                                                   city: "",
                                                   province: "",
                                                   postalCode: "12345")]
            return .init(name: "John Doe",
                         vatRegistered: false,
                         contactInformation: contactInformation,
                         taxNumber: "1234567890",
                         legalStatus: .individual,
                         website: "",
                         businessAddress: businessAddress,
                         paymentTermsDays: 30,
                         note: "This is a note")
        }
    }
}
