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
        let kind: ContactKind
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        let groupIds: [UUID]?
        let paymentTermsDays: Int?
        
        let businessAddress: CreateBusinessAddress?
        let shippingAddress: CreateShippingAddress?
        
        init(
            name: String,
            kind: ContactKind = .customer,
            vatRegistered: Bool = false,
            contactInformation: ContactInformation? = nil,
            taxNumber: String? = nil,
            legalStatus: BusinessType = .individual,
            website: String? = nil,
            note: String? = nil,
            groupIds: [UUID]? = nil,
            paymentTermsDays: Int? = nil,
            businessAddress: CreateBusinessAddress? = nil,
            shippingAddress: CreateShippingAddress? = nil
        ) {
            self.name = name
            self.kind = kind
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
            self.groupIds = groupIds
            self.paymentTermsDays = paymentTermsDays
            self.businessAddress = businessAddress
            self.shippingAddress = shippingAddress
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.kind = try container.decode(ContactKind.self, forKey: .kind)
            self.legalStatus = try container.decode(BusinessType.self, forKey: .legalStatus)
            self.vatRegistered = try container.decode(Bool.self, forKey: .vatRegistered)
            self.contactInformation = try container.decodeIfPresent(ContactInformation.self, forKey: .contactInformation)
            self.taxNumber = try container.decodeIfPresent(String.self, forKey: .taxNumber)
            self.website = try container.decodeIfPresent(String.self, forKey: .website)
            self.note = try container.decodeIfPresent(String.self, forKey: .note)
            self.groupIds = try container.decodeIfPresent([UUID].self, forKey: .groupIds)
            self.paymentTermsDays = try container.decodeIfPresent(Int.self, forKey: .paymentTermsDays)
            self.businessAddress = try container.decodeIfPresent(CreateBusinessAddress.self, forKey: .businessAddress)
            self.shippingAddress = try container.decodeIfPresent(CreateShippingAddress.self, forKey: .shippingAddress)
        }


        static func validations(_ validations: inout Validations) {
            validations.add(
                "name", as: String.self,
                is: .count(3...200),
                required: true)
            validations.add(
                "kind", as: ContactKind.self,
                required: true)
            validations.add(
                "tax_number", as: String.self,
                is: .count(13...13),
                required: false)
            validations.add(
                "legal_status", as: BusinessType.self,
                required: true) 

        }

        enum CodingKeys: String, CodingKey {
            case name
            case kind
            case groupIds = "group_ids"
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case paymentTermsDays = "payment_terms_days"
            case businessAddress = "business_address"
            case shippingAddress = "shipping_address"
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let kind: ContactKind?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?
        let note: String?
        let paymentTermsDays: Int?
        let groupIds: [UUID]?

        init(
            name: String? = nil,
            kind: ContactKind? = nil,            
            vatRegistered: Bool? = nil,
            contactInformation: ContactInformation? = nil,
            taxNumber: String? = nil,
            legalStatus: BusinessType? = nil,
            website: String? = nil,
            note: String? = nil,
            paymentTermsDays: Int? = nil,
            groupIds: [UUID]? = nil
        ) {
            self.name = name
            self.kind = kind
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
            self.paymentTermsDays = paymentTermsDays
            self.groupIds = groupIds
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "name", as: String.self,
                is: .count(3...200),
                required: false)
            validations.add(
                "tax_number", as: String.self,
                is: .count(13...13),
                required: false)
            validations.add(
                "kind", as: ContactKind.self,
                required: false)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case kind
            case groupIds = "group_ids"
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case paymentTermsDays = "payment_terms_days"
        }
    }

    struct UpdateBusinessAddress: Content, Validatable {
        let address: String?
        let branch: String?
        let branchCode: String?
        let subDistrict: String?
        let district: String?
        let province: String?
        let country: String?
        let postalCode: String?
        let phone: String?
        let email: String?
        let fax: String?

        init(
            address: String? = nil,
            branch: String? = nil,
            branchCode: String? = nil,
            subDistrict: String? = nil,
            district: String? = nil,
            province: String? = nil,
            country: String? = nil,
            postalCode: String? = nil,
            phone: String? = nil,
            email: String? = nil,
            fax: String? = nil
        ) {
            self.address = address
            self.branch = branch
            self.branchCode = branchCode
            self.subDistrict = subDistrict
            self.district = district
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
            self.email = email
            self.fax = fax
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "postal_code",
                as: String.self,
                is: .count(5...5),
                required: false)
            validations.add(
                "address",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "sub_district",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "district",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "province",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "country",
                as: String.self,
                is: .count(1...300),
                required: false)

        }

        enum CodingKeys: String, CodingKey {
            case branch
            case branchCode = "branch_code"
            case address
            case subDistrict = "sub_district"
            case district
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
        let district: String?
        let province: String?
        let country: String?
        let postalCode: String?
        let phone: String?

        init(
            address: String? = nil,
            subDistrict: String? = nil,
            district: String? = nil,
            province: String? = nil,
            country: String? = nil,
            postalCode: String? = nil,
            phone: String? = nil
        ) {
            self.address = address
            self.subDistrict = subDistrict
            self.district = district
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "postal_code",
                as: String.self,
                is: .count(5...5),
                required: false)
            validations.add(
                "address",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "sub_district",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "district",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "province",
                as: String.self,
                is: .count(1...300),
                required: false)
            validations.add(
                "country",
                as: String.self,
                is: .count(1...300),
                required: false)
        }

        enum CodingKeys: String, CodingKey {
            case address
            case subDistrict = "sub_district"
            case district
            case province
            case postalCode = "postal_code"
            case country
            case phone
        }
    }

    struct UpdateBusinessAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: ContactRequest.UpdateBusinessAddress
    }

    struct UpdateShippingAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: ContactRequest.UpdateShippingAddress
    }

    struct AddToGroup: Content, Validatable {
        let toGroupId: UUID
        let contactIds: [UUID]

        init(toGroupId: UUID, contactIds: [UUID]) {
            self.toGroupId = toGroupId
            self.contactIds = contactIds
        }

        enum CodingKeys: String, CodingKey {
            case toGroupId = "to_group_id"
            case contactIds = "contact_ids"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add(
                "contact_ids",
                as: [UUID].self,
                required: true
            )
            validations.add(
                "to_group_id",
                as: UUID.self,
                required: true
            )
        }
    }
    
    struct CreateBusinessAddress: Content, Validatable  {
        let branchName: String
        let branchCode: String
        
        let address: String
        let subDistrict: String
        let district: String
        let province: String
        let country: String
        let postalCode: String
        
        let phone: String?
        let fax: String?
        let email: String?
        
        init(branchName: String,
             branchCode: String,
             address: String,
             subDistrict: String,
             district: String,
             province: String,
             country: String,
             postalCode: String,
             phone: String?,
             fax: String?,
             email: String?) {
            self.address = address
            self.subDistrict = subDistrict
            self.district = district
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.branchCode = branchCode
            self.branchName = branchName
            self.phone = phone
            self.fax = fax
            self.email = email
        }
        
        //decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.branchName = try container.decode(String.self, forKey: .branchName)
            self.branchCode = try container.decode(String.self, forKey: .branchCode)
            
            self.address = try container.decode(String.self, forKey: .address)
            self.subDistrict = try container.decode(String.self, forKey: .subDistrict)
            self.district = try container.decode(String.self, forKey: .district)
            self.province = try container.decode(String.self, forKey: .province)
            self.country = try container.decode(String.self, forKey: .country)
            self.postalCode = try container.decode(String.self, forKey: .postalCode)
            
            self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
            self.fax = try container.decodeIfPresent(String.self, forKey: .fax)
            self.email = try container.decodeIfPresent(String.self, forKey: .email)
        }
        
        func toBusinessAddress() -> BusinessAddress {
            return BusinessAddress(branch: branchName,
                                   branchCode: branchCode,
                                   address: address,
                                   subDistrict: subDistrict,
                                   district: district,
                                   province: province,
                                   postalCode: postalCode,
                                   country: country,
                                   phone: phone ?? "",
                                   email: email ?? "",
                                   fax: fax ?? "")
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("branch_name",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("branch_code",
                            as: String.self,
                            is: .count(5...5),
                            required: true)
            validations.add("postal_code",
                            as: String.self,
                            is: .count(5...5),
                            required: true)
            validations.add("address",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("sub_district",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("district",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("province",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("country",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("phone",
                            as: String.self,
                            is: .count(10...10),
                            required: false)
            validations.add("fax",
                            as: String.self,
                            is: .count(1...10),
                            required: false)
            validations.add("email",
                            as: String.self,
                            is: .count(1...100),
                            required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case branchName = "branch"
            case branchCode = "branch_code"
            case address
            case subDistrict = "sub_district"
            case district
            case province
            case postalCode = "postal_code"
            case country
            case phone
            case fax
            case email
        }
    }
    
    struct CreateShippingAddress: Content, Validatable {
        let address: String
        let subDistrict: String
        let district: String
        let province: String
        let country: String
        let postalCode: String
        let phone: String?
        
        init(address: String,
             subDistrict: String,
             district: String,
             province: String,
             country: String,
             postalCode: String,
             phone: String? = nil) {
            self.address = address
            self.subDistrict = subDistrict
            self.district = district
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
        }
        
        //decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.address = try container.decode(String.self, forKey: .address)
            self.subDistrict = try container.decode(String.self, forKey: .subDistrict)
            self.district = try container.decode(String.self, forKey: .district)
            self.province = try container.decode(String.self, forKey: .province)
            self.country = try container.decode(String.self, forKey: .country)
            self.postalCode = try container.decode(String.self, forKey: .postalCode)
            self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        }
        
        func toShippingAddress() -> ShippingAddress {
            return ShippingAddress(address: address,
                                   subDistrict: subDistrict,
                                   district: district,
                                   province: province,
                                   country: country,
                                   postalCode: postalCode,
                                   phone: phone ?? "")
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("postal_code",
                            as: String.self,
                            is: .count(5...5),
                            required: true)
            validations.add("address",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("sub_district",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("district",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("province",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("country",
                            as: String.self,
                            is: .count(1...300),
                            required: true)
            validations.add("phone",
                            as: String.self,
                            is: .count(10...10),
                            required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case address
            case subDistrict = "sub_district"
            case district
            case province
            case postalCode = "postal_code"
            case country
            case phone
        }
    }
}
