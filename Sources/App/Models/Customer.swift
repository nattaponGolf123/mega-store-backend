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

    struct ContactInformation: Content {
        var contactPerson: String
        var phoneNumber: String
        var email: String
        var address: String

        init(contactPerson: String,
             phoneNumber: String = "",
             email: String = "",
             address: String = "") {
            self.contactPerson = contactPerson
            self.phoneNumber = phoneNumber
            self.email = email
            self.address = address
        }   

        //encode
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contactPerson, forKey: .contactPerson)
            try container.encode(phoneNumber, forKey: .phoneNumber)
            try container.encode(email, forKey: .email)
            try container.encode(address, forKey: .address)
        }

        //decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.contactPerson = try container.decode(String.self,
                                                      forKey: .contactPerson)
            self.phoneNumber = try container.decode(String.self,
                                                    forKey: .phoneNumber)
            self.email = try container.decode(String.self,
                                              forKey: .email)
            self.address = try container.decode(String.self,
                                               forKey: .address)
        }

        enum CodingKeys: String, CodingKey {
            case contactPerson = "contact_person"
            case phoneNumber = "phone_number"
            case email
            case address
        }

    }

}

extension Customer {
    struct Stub {
        
        static var individul: Customer {

            let contactInformation = ContactInformation(contactPerson: "John Doe",
                                                                  phoneNumber: "1234567890",
                                                                  email: "",
                                                                    address: "123 Main St")
            let businessAddress = [BusinessAddress(address: "123 Main St",
                                                            branch: "Main",
                                                            city: "New York",
                                                            postalCode: "10001",
                                                            country: "USA",
                                                            phoneNumber: "1234567890",
                                                            email: "",
                                                            fax: "")]
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
