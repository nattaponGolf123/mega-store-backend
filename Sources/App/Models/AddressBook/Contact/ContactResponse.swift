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

    init(from: Contact) {
        self.id = from.id
        self.code = ContactCode(number: from.number).code
        self.name = from.name
        self.kind = from.kind
        self.groupId = from.groupId
        self.number = from.number
        self.vatRegistered = from.vatRegistered
        self.contactInformation = from.contactInformation
        self.taxNumber = from.taxNumber
        self.legalStatus = from.legalStatus
        self.website = from.website
        self.businessAddress = from.businessAddress
        self.shippingAddress = from.shippingAddress
        self.paymentTermsDays = from.paymentTermsDays
        self.note = from.note
        self.createdAt = from.createdAt
        self.updatedAt = from.updatedAt
        self.deletedAt = from.deletedAt    
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
