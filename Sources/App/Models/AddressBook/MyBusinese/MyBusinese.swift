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
    var website: String?
    
    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]
    
    // logo image url
    @Field(key: "logo")
    var logo: String?
    
    // stamp logo image url
    @Field(key: "stamp_logo")
    var stampLogo: String?
    
    // authorized sign signature image url
    @Field(key: "authorized_sign_signature")
    var authorizedSignSignature: String?
    
    @Field(key: "note")
    var note: String?
    
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
         vatRegistered: Bool = false,
         contactInformation: ContactInformation? = .init(),
         taxNumber: String,
         legalStatus: BusinessType = .individual,
         website: String? = nil,
         businessAddress: [BusinessAddress] = [.init()],
         shippingAddress: [ShippingAddress] = [.init()],
         logo: String? = nil,
         stampLogo: String? = nil,
         authorizedSignSignature: String? = nil,
         note: String? = nil,
         createdAt: Date? = .init(),
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? UUID()
        self.name = name
        self.vatRegistered = vatRegistered
        self.contactInformation = contactInformation ?? .init()
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.shippingAddress = shippingAddress
        self.logo = logo
        self.stampLogo = stampLogo
        self.authorizedSignSignature = authorizedSignSignature
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
}


extension MyBusinese {
    struct Stub {
        static var myCompany: MyBusinese {
            MyBusinese(id: UUID(),
                       name: "ABC Industries",
                       vatRegistered: true,
                       contactInformation: ContactInformation(contactPerson: "John Doe",
                                                              phone: "123-456-7890",
                                                              email: "abc@email.com"),
                       taxNumber: "123123212123",
                       legalStatus: .companyLimited,
                       website: "www.abcindustries.com",
                       businessAddress: [BusinessAddress.Stub.usa],
                       shippingAddress: [ShippingAddress.Stub.home],
                       logo: "https://www.abcindustries.com/logo.png",
                       stampLogo: "https://www.abcindustries.com/stamp.png",
                       authorizedSignSignature: "https://www.abcindustries.com/signature.png",
                       note: "Reliable supplier with consistent quality and delivery times.")
        }
    }
}
