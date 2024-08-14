//
//  File.swift
//  
//
//  Created by IntrodexMac on 29/7/2567 BE.
//

import Foundation
import Vapor

struct ContactRequest {
    
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        let groupId: UUID?
        let paymentTermsDays: Int?
        
        init(name: String, 
             vatRegistered: Bool = false,
             contactInformation: ContactInformation? = nil,
             taxNumber: String? = nil,
             legalStatus: BusinessType = .individual,
             website: String? = nil,
             note: String? = nil,
             groupId: UUID? = nil,
             paymentTermsDays: Int? = nil) {
            self.name = name
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
            self.groupId = groupId
            self.paymentTermsDays = paymentTermsDays
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: true)
            validations.add("tax_number", as: String.self,
                            is: .count(13...13),
                            required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case groupId = "group_id"
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case paymentTermsDays = "payment_terms_days"
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?
        let note: String?
        let paymentTermsDays: Int?
        let groupId: UUID?
        
        init(name: String? = nil,
             vatRegistered: Bool? = nil,
             contactInformation: ContactInformation? = nil,
             taxNumber: String? = nil,
             legalStatus: BusinessType? = nil,
             website: String? = nil,
             note: String? = nil,
             paymentTermsDays: Int? = nil,
             groupId: UUID? = nil) {
            self.name = name
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
            self.paymentTermsDays = paymentTermsDays
            self.groupId = groupId
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: false)
            validations.add("tax_number", as: String.self,
                            is: .count(13...13),
                            required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case groupId = "group_id"
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case paymentTermsDays = "payment_terms_days"
        }
    }
    
    struct UpdateBussineseAddress: Content, Validatable {
        let address: String?
        let branch: String?
        let branchCode: String?
        let subDistrict: String?
        let city: String?
        let province: String?
        let country: String?
        let postalCode: String?
        let phone: String?
        let email: String?
        let fax: String?
        
        init(address: String? = nil,
             branch: String? = nil,
             branchCode: String? = nil,
             subDistrict: String? = nil,
             city: String? = nil,
             province: String? = nil,
             country: String? = nil,
             postalCode: String? = nil,
             phone: String? = nil,
             email: String? = nil,
             fax: String? = nil) {
            self.address = address
            self.branch = branch
            self.branchCode = branchCode
            self.subDistrict = subDistrict
            self.city = city
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
            self.email = email
            self.fax = fax
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("postal_code",
                            as: String.self,
                            is: .count(5...5),
                            required: false)
            validations.add("address", 
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("sub_district", 
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("city",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("province", 
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("country",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            
        }
        
        enum CodingKeys: String, CodingKey {
            case branch
            case branchCode = "branch_code"
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone
            case email
            case fax
        }
    }
    
    struct UpdateShippingAddress: Content, Validatable {
        let address: String?
        let subDistrict: String?
        let city: String?
        let province: String?
        let country: String?
        let postalCode: String?
        let phone: String?
        
        init(address: String? = nil,
             subDistrict: String? = nil,
             city: String? = nil,
             province: String? = nil,
             country: String? = nil,
             postalCode: String? = nil,
             phone: String? = nil) {
            self.address = address
            self.subDistrict = subDistrict
            self.city = city
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("postal_code",
                            as: String.self,
                            is: .count(5...5),
                            required: false)
            validations.add("address",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("sub_district",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("city",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("province",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
            validations.add("country",
                            as: String.self,
                            is: .count(1...300),
                            required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone
        }
    }
    
    struct UpdateBusineseAdressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: ContactRequest.UpdateBussineseAddress
    }
    
    struct UpdateShippingAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: ContactRequest.UpdateShippingAddress
    }
}

//extension ContactRequest {
//    enum SortBy: String, Codable, Sortable {
//        case name
//        case number
//        case groupId = "group_id"
//        case createdAt = "created_at"
//        
//        static func == (lhs: Self, rhs: Self) -> Bool {
//            return lhs.rawValue == rhs.rawValue
//        }
//    }
//}
