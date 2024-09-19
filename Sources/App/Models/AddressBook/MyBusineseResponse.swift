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
//    let name: String
//    let vatRegistered: Bool
//    let contactInformation: ContactInformation
//    let taxNumber: String?
//    let legalStatus: BusinessType
//    let website: String?
//    let businessAddress: [BusinessAddress]
//    let shippingAddress: [ShippingAddress]
//    let paymentTermsDays: Int
//    let note: String?
//    let createdAt: Date?
//    let updatedAt: Date?
//    let deletedAt: Date?
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
