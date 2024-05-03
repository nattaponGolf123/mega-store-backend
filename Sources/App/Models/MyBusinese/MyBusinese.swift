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
        self.logo = logo
        self.stampLogo = stampLogo
        self.authorizedSignSignature = authorizedSignSignature
        self.note = note
    }

    struct ContactInformation: Content {
        var contactPerson: String
        var phoneNumber: String        
        var email: String
        var address: String

        enum CodingKeys: String, CodingKey {
            case contactPerson = "contact_person"
            case phoneNumber = "phone_number"
            case email
            case address
        }
    }

    struct BusinessAddress: Content {
        var address: String
        var branch: String        
        var city: String
        var postalCode: String
        var country: String
        var phoneNumber: String
        var email: String
        var fax: String

        enum CodingKeys: String, CodingKey {            
            case address
            case branch
            case city
            case postalCode = "postal_code"
            case country
            case phoneNumber = "phone_number"
            case email
            case fax
        }
    }

}

extension MyBusinese {
    struct Stub {
        static var myCompany: MyBusinese {
            MyBusinese(id: UUID(),
                                   name: "ABC Industries",
                                   vatRegistered: true,
                                   contactInformation: MyBusinese.ContactInformation(contactPerson: "John Doe",
                                                                                     phoneNumber: "123-456-7890",
                                                                                     email: "abc@email.com",
                                                                                        address: "1234 Industrial Way, Business City, BC 56789"),
                                      taxNumber: "123123212123",
                                        legalStatus: .limitedCompany,
                                        website: "www.abcindustries.com",
                                        businessAddress: [MyBusinese.BusinessAddress(address: "123",
                                                                                        branch: "123",
                                                                                      city: "Bangkok",
                                                                                      postalCode: "12022",
                                                                                      country: "Thailand",
                                                                                      phoneNumber: "123-456-7890",
                                                                                      email: "",
                                                                                      fax: "")],
                                        logo: "https://www.abcindustries.com/logo.png",
                                        stampLogo: "https://www.abcindustries.com/stamp.png",
                                        authorizedSignSignature: "https://www.abcindustries.com/signature.png",
                                        note: "Reliable supplier with consistent quality and delivery times.")
        } 
    }
}

/*
{
    "id": "SUP12345", // UUID
    "name": "ABC Industries",
    "vat_registered": true,
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
    "logo" : "https://www.abcindustries.com/logo.png",
    "stamp_logo" : "https://www.abcindustries.com/stamp.png",
    "authorized_sign_signature" : "https://www.abcindustries.com/signature.png",
    "note": "Reliable supplier with consistent quality and delivery times.",
    "created_at": "2021-03-05T07:00:00Z",
    "updated_at": "2021-03-05T07:00:00Z",
    "deleted_at": null
}
*/
