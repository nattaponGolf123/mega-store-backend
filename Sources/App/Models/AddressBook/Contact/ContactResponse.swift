//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor

struct ContactResponse: Content {
    let id: UUID?
    let code: String
    let name: String
    let kind: ContactKind
    let groupId: UUID?
    let number: Int
    let vatRegistered: Bool
    let contactInformation: ContactInformation
    let taxNumber: String
    let legalStatus: BusinessType
    let website: String?
    let businessAddress: [BusinessAddress]
    let shippingAddress: [ShippingAddress]
    let paymentTermsDays: Int
    let note: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?

    init(contact: Contact) {
        self.id = contact.id
        self.code = ContactCode(number: contact.number).code
        self.name = contact.name
        self.kind = contact.kind
        self.groupId = contact.groupId
        self.number = contact.number
        self.vatRegistered = contact.vatRegistered
        self.contactInformation = contact.contactInformation
        self.taxNumber = contact.taxNumber
        self.legalStatus = contact.legalStatus
        self.website = contact.website
        self.businessAddress = contact.businessAddress
        self.shippingAddress = contact.shippingAddress
        self.paymentTermsDays = contact.paymentTermsDays
        self.note = contact.note
        self.createdAt = contact.createdAt
        self.updatedAt = contact.updatedAt
        self.deletedAt = contact.deletedAt    
    }

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case kind
        case groupId = "group_id"
        case number
        case vatRegistered = "vat_registered"
        case contactInformation = "contact_information"
        case taxNumber = "tax_number"
        case legalStatus = "legal_status"
        case website
        case businessAddress = "business_address"
        case shippingAddress = "shipping_address"
        case paymentTermsDays = "payment_terms_days"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
}


//
//final class Contact: Model, Content {
//    static let schema = "Contacts"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Field(key: "number")
//    var number: Int
//    
//    @Enum(key: "kind")
//    var kind: ContactKind
//    
//    @Field(key: "group_id")
//    var groupId: UUID?
//    
//    @Field(key: "name")
//    var name: String
//    
//    @Field(key: "vat_registered")
//    var vatRegistered: Bool
//    
//    @Field(key: "contact_information")
//    var contactInformation: ContactInformation
//    
//    @Field(key: "tax_number")
//    var taxNumber: String
//    
//    @Enum(key: "legal_status")
//    var legalStatus: BusinessType
//    
//    @Field(key: "website")
//    var website: String?
//    
//    @Field(key: "business_address")
//    var businessAddress: [BusinessAddress]
//    
//    @Field(key: "shipping_address")
//    var shippingAddress: [ShippingAddress]
//    
//    @Field(key: "payment_terms_days")
//    var paymentTermsDays: Int
//    
//    @Field(key: "note")
//    var note: String?
//    
//    @Timestamp(key: "created_at",
//               on: .create,
//               format: .iso8601)
//    var createdAt: Date?
//    
//    @Timestamp(key: "updated_at",
//               on: .update,
//               format: .iso8601)
//    var updatedAt: Date?
//    
//    @Timestamp(key: "deleted_at",
//               on: .delete,
//               format: .iso8601)
//    var deletedAt: Date?
//    
//    init() { }
//    
//    init(id: UUID? = nil,
//         number: Int = 1,
//         name: String = "",
//         groupId: UUID? = nil,
//         kind: ContactKind = .both,
//         vatRegistered: Bool = false,
//         contactInformation: ContactInformation = .init(),
//         taxNumber: String = "",
//         legalStatus: BusinessType = .individual,
//         website: String? = nil,
//         businessAddress: [BusinessAddress] = [.init()],
//         shippingAddress: [ShippingAddress] = [.init()],
//         paymentTermsDays: Int = 30,
//         note: String? = nil) {
//        
//        self.id = id ?? UUID()
//        //self.code = ContactCode(number: number).code
//        self.number = number
//        self.groupId = groupId
//        self.kind = kind
//        self.name = name
//        self.vatRegistered = vatRegistered
//        self.contactInformation = contactInformation
//        self.taxNumber = taxNumber
//        self.legalStatus = legalStatus
//        self.website = website
//        self.businessAddress = businessAddress
//        self.shippingAddress = shippingAddress
//        self.paymentTermsDays = paymentTermsDays
//        self.note = note
//    }
//    
//}
