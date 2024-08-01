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
    let taxNumber: String?
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
