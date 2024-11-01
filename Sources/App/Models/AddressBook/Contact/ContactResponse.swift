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
    let groups: [ContactGroupResponse]
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

    init(from: Contact, groups: [ContactGroup]) {
        self.id = from.id
        self.code = ContactCode(number: from.number).code
        self.name = from.name
        self.kind = from.kind
        self.groups = groups.map { ContactGroupResponse(from: $0) }
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

    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.kind = try container.decode(ContactKind.self, forKey: .kind)
        self.groups = try container.decode([ContactGroupResponse].self, forKey: .groups)
        self.number = try container.decode(Int.self, forKey: .number)
        self.vatRegistered = try container.decode(Bool.self, forKey: .vatRegistered)
        self.contactInformation = try container.decode(ContactInformation.self, forKey: .contactInformation)
        self.taxNumber = try container.decodeIfPresent(String.self, forKey: .taxNumber)
        self.legalStatus = try container.decode(BusinessType.self, forKey: .legalStatus)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.businessAddress = try container.decode([BusinessAddress].self, forKey: .businessAddress)
        self.shippingAddress = try container.decode([ShippingAddress].self, forKey: .shippingAddress)
        self.paymentTermsDays = try container.decode(Int.self, forKey: .paymentTermsDays)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        
        let dateFormat = Date.Format.iso8601
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)?.tryToDate(dateFormat)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)?.tryToDate(dateFormat)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)?.tryToDate(dateFormat)
    }

    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.kind, forKey: .kind)
        try container.encode(self.groups, forKey: .groups)
        try container.encode(self.number, forKey: .number)
        try container.encode(self.vatRegistered, forKey: .vatRegistered)
        try container.encode(self.contactInformation, forKey: .contactInformation)
        try container.encode(self.taxNumber, forKey: .taxNumber)
        try container.encode(self.legalStatus, forKey: .legalStatus)
        try container.encode(self.website, forKey: .website)
        try container.encode(self.businessAddress, forKey: .businessAddress)
        try container.encode(self.shippingAddress, forKey: .shippingAddress)
        try container.encode(self.paymentTermsDays, forKey: .paymentTermsDays)
        try container.encode(self.note, forKey: .note)
        
        let dateFormat = Date.Format.iso8601
        try container.encode(self.createdAt?.toDateString(dateFormat), forKey: .createdAt)
        try container.encode(self.updatedAt?.toDateString(dateFormat), forKey: .updatedAt)
        try container.encode(self.deletedAt?.toDateString(dateFormat), forKey: .deletedAt)
    }
    

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case kind
        case groups
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
