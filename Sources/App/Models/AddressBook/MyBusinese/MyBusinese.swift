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

/*

extension CustomerGroup {
    struct Create: Content, Validatable {
        let name: String
        let description: String?
        
        init(name: String,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                     forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        
        init(name: String? = nil,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
}
*/

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
