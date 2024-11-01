//
//  File.swift
//  poc-swift-vapor-rest
//
//  Created by IntrodexMac on 19/9/2567 BE.
//

import Foundation
import Vapor

struct MyBusineseResponse: Content {
    let id: UUID?
    let name: String
    let vatRegistered: Bool //= false,
    let contactInformation: ContactInformation? //= .init(),
    let taxNumber: String
    let legalStatus: BusinessType //= .individual,
    let website: String? //= nil,
    let businessAddress: [BusinessAddress] //= [.init()],
    let shippingAddress: [ShippingAddress] //= [.init()],
    let logo: String? //= nil,
    let stampLogo: String? //= nil,
    let authorizedSignSignature: String? //= nil,
    let note: String? //= nil,
    let createdAt: Date? //= .init(),
    let updatedAt: Date? //= nil,
    let deletedAt: Date? //= nil

    init(from: MyBusinese) {
        self.id = from.id
        self.name = from.name
        self.vatRegistered = from.vatRegistered
        self.contactInformation = from.contactInformation
        self.taxNumber = from.taxNumber
        self.legalStatus = from.legalStatus
        self.website = from.website
        self.businessAddress = from.businessAddress
        self.shippingAddress = from.shippingAddress
        self.logo = from.logo
        self.stampLogo = from.stampLogo
        self.authorizedSignSignature = from.authorizedSignSignature
        self.note = from.note
        self.createdAt = from.createdAt
        self.updatedAt = from.updatedAt
        self.deletedAt = from.deletedAt
    }

    // decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.vatRegistered = try container.decode(Bool.self, forKey: .vatRegistered)
        self.contactInformation = try container.decodeIfPresent(ContactInformation.self, forKey: .contactInformation)
        self.taxNumber = try container.decode(String.self, forKey: .taxNumber)
        self.legalStatus = try container.decode(BusinessType.self, forKey: .legalStatus)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.businessAddress = try container.decode([BusinessAddress].self, forKey: .businessAddress)
        self.shippingAddress = try container.decode([ShippingAddress].self, forKey: .shippingAddress)
        self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
        self.stampLogo = try container.decodeIfPresent(String.self, forKey: .stampLogo)
        self.authorizedSignSignature = try container.decodeIfPresent(String.self, forKey: .authorizedSignSignature)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        let dateFormat = Date.Format.iso8601
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)?.tryToDate(dateFormat)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)?.tryToDate(dateFormat)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)?.tryToDate(dateFormat)
    }

    // encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.vatRegistered, forKey: .vatRegistered)
        try container.encode(self.contactInformation, forKey: .contactInformation)
        try container.encode(self.taxNumber, forKey: .taxNumber)
        try container.encode(self.legalStatus, forKey: .legalStatus)
        try container.encode(self.website, forKey: .website)
        try container.encode(self.businessAddress, forKey: .businessAddress)
        try container.encode(self.shippingAddress, forKey: .shippingAddress)
        try container.encode(self.logo, forKey: .logo)
        try container.encode(self.stampLogo, forKey: .stampLogo)
        try container.encode(self.authorizedSignSignature, forKey: .authorizedSignSignature)
        try container.encode(self.note, forKey: .note)
        let dateFormat = Date.Format.iso8601
        try container.encode(self.createdAt?.toDateString(dateFormat), forKey: .createdAt)
        try container.encode(self.updatedAt?.toDateString(dateFormat), forKey: .updatedAt)
        try container.encode(self.deletedAt?.toDateString(dateFormat), forKey: .deletedAt)
    }


    enum CodingKeys: String, CodingKey {
        case id
        case name
        case vatRegistered = "vat_registered"
        case contactInformation = "contact_information"
        case taxNumber = "tax_number"
        case legalStatus = "legal_status"
        case website
        case businessAddress = "business_address"
        case shippingAddress = "shipping_address"
        case logo
        case stampLogo = "stamp_logo"
        case authorizedSignSignature = "authorized_sign_signature"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        
    }
    
}
