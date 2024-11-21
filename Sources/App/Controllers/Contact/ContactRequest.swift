//
//  File.swift
//
//
//  Created by IntrodexMac on 29/7/2567 BE.
//

import Foundation
import Vapor

struct ContactRequest {
    struct Search: Content, Validatable {
        let query: String
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        let showDeleted: Bool
        let groupId: UUID?
        let kind: ContactKind?
        
        static let minPageRange: (min: Int, max: Int) = (1, .max)
        static let perPageRange: (min: Int, max: Int) = (10, 1000)
        
        init(query: String,
             page: Int = Self.minPageRange.min,
             perPage: Int = Self.perPageRange.min,
             sortBy: SortBy = .createdAt,
             sortOrder: SortOrder = .asc,
             showDeleted: Bool = false,
             groupId: UUID? = nil,
             kind: ContactKind? = nil) {
            self.query = query
            self.page = min(max(page, Self.minPageRange.min), Self.minPageRange.max)
            self.perPage = min(max(perPage, Self.perPageRange.min), Self.perPageRange.max)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self.showDeleted = showDeleted
            self.groupId = groupId
            self.kind = kind
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.query = try container.decode(String.self, forKey: .query)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? Self.minPageRange.min
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? Self.perPageRange.min
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .createdAt
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.groupId = try container.decodeIfPresent(UUID.self, forKey: .groupId)
            self.kind = try container.decodeIfPresent(ContactKind.self, forKey: .kind)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(query, forKey: .query)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encodeIfPresent(groupId, forKey: .groupId)
            try container.encodeIfPresent(kind, forKey: .kind)
        }
        
        enum CodingKeys: String, CodingKey {
            case query = "q"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
            case showDeleted = "show_deleted"
            case groupId = "group_id"
            case kind
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("q", as: String.self,
                            is: .count(1...200),
                            required: true)
        }
    }
    
    struct FetchAll: Content {
        let groupId: UUID?
        let kind: ContactKind?
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder

        static let minPageRange: (min: Int, max: Int) = (1, .max)
        static let perPageRange: (min: Int, max: Int) = (10, 1000)

        init(groupId: UUID? = nil,
             kind: ContactKind? = nil,
             showDeleted: Bool = false,
             page: Int = Self.minPageRange.min,
             perPage: Int = Self.perPageRange.min,
             sortBy: SortBy = .createdAt,
             sortOrder: SortOrder = .asc
        ) {
            self.groupId = groupId
            self.kind = kind
            self.showDeleted = showDeleted
            self.page = min(max(page, Self.minPageRange.min), Self.minPageRange.max)
            self.perPage = min(max(perPage, Self.perPageRange.min), Self.perPageRange.max)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            groupId = try container.decodeIfPresent(UUID.self, forKey: .groupId)
            kind = (try? container.decodeIfPresent(ContactKind.self, forKey: .kind)) ?? .both
            showDeleted = (try? container.decodeIfPresent(Bool.self, forKey: .showDeleted)) ?? false
            page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? Self.minPageRange.min
            perPage = (try? container.decodeIfPresent(Int.self, forKey: .perPage)) ?? Self.perPageRange.min
            sortBy = (try? container.decodeIfPresent(SortBy.self, forKey: .sortBy)) ?? .createdAt
            sortOrder = (try? container.decodeIfPresent(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(groupId, forKey: .groupId)
            try container.encodeIfPresent(kind, forKey: .kind)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

        enum CodingKeys: String, CodingKey {
            case groupId = "group_id"
            case kind
            case showDeleted = "show_deleted"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }

    struct Create: Content, Validatable {
        let name: String
        let kind: ContactKind
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        let groupIds: [UUID]
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
            groupIds: [UUID] = [],
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
            name = try container.decode(String.self, forKey: .name)
            kind = try container.decode(ContactKind.self, forKey: .kind)
            legalStatus = try container.decode(BusinessType.self, forKey: .legalStatus)
            vatRegistered = try container.decode(Bool.self, forKey: .vatRegistered)
            contactInformation = try container.decodeIfPresent(ContactInformation.self, forKey: .contactInformation)
            taxNumber = try container.decodeIfPresent(String.self, forKey: .taxNumber)
            website = try container.decodeIfPresent(String.self, forKey: .website)
            note = try container.decodeIfPresent(String.self, forKey: .note)
            groupIds = (try? container.decodeIfPresent([UUID].self, forKey: .groupIds)) ?? []
            paymentTermsDays = try container.decodeIfPresent(Int.self, forKey: .paymentTermsDays)
            businessAddress = try container.decodeIfPresent(CreateBusinessAddress.self, forKey: .businessAddress)
            shippingAddress = try container.decodeIfPresent(CreateShippingAddress.self, forKey: .shippingAddress)
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "name", as: String.self,
                is: .count(3 ... 200),
                required: true
            )
            validations.add(
                "kind", as: ContactKind.self,
                required: true
            )
            validations.add(
                "tax_number", as: String.self,
                is: .count(13 ... 13),
                required: false
            )
            validations.add(
                "legal_status", as: BusinessType.self,
                required: true
            )
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
                is: .count(3 ... 200),
                required: false
            )
            validations.add(
                "tax_number", as: String.self,
                is: .count(13 ... 13),
                required: false
            )
            validations.add(
                "kind", as: ContactKind.self,
                required: false
            )
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
                is: .count(5 ... 5),
                required: false
            )
            validations.add(
                "address",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "sub_district",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "district",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "province",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "country",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
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
                is: .count(5 ... 5),
                required: false
            )
            validations.add(
                "address",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "sub_district",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "district",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "province",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
            validations.add(
                "country",
                as: String.self,
                is: .count(1 ... 300),
                required: false
            )
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

    struct CreateBusinessAddress: Content, Validatable {
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
             email: String?)
        {
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

        // decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            branchName = try container.decode(String.self, forKey: .branchName)
            branchCode = try container.decode(String.self, forKey: .branchCode)

            address = try container.decode(String.self, forKey: .address)
            subDistrict = try container.decode(String.self, forKey: .subDistrict)
            district = try container.decode(String.self, forKey: .district)
            province = try container.decode(String.self, forKey: .province)
            country = try container.decode(String.self, forKey: .country)
            postalCode = try container.decode(String.self, forKey: .postalCode)

            phone = try container.decodeIfPresent(String.self, forKey: .phone)
            fax = try container.decodeIfPresent(String.self, forKey: .fax)
            email = try container.decodeIfPresent(String.self, forKey: .email)
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
                            is: .count(1 ... 300),
                            required: true)
            validations.add("branch_code",
                            as: String.self,
                            is: .count(5 ... 5),
                            required: true)
            validations.add("postal_code",
                            as: String.self,
                            is: .count(5 ... 5),
                            required: true)
            validations.add("address",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("sub_district",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("district",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("province",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("country",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("phone",
                            as: String.self,
                            is: .count(10 ... 10),
                            required: false)
            validations.add("fax",
                            as: String.self,
                            is: .count(1 ... 10),
                            required: false)
            validations.add("email",
                            as: String.self,
                            is: .count(1 ... 100),
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
             phone: String? = nil)
        {
            self.address = address
            self.subDistrict = subDistrict
            self.district = district
            self.province = province
            self.country = country
            self.postalCode = postalCode
            self.phone = phone
        }

        // decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            address = try container.decode(String.self, forKey: .address)
            subDistrict = try container.decode(String.self, forKey: .subDistrict)
            district = try container.decode(String.self, forKey: .district)
            province = try container.decode(String.self, forKey: .province)
            country = try container.decode(String.self, forKey: .country)
            postalCode = try container.decode(String.self, forKey: .postalCode)
            phone = try container.decodeIfPresent(String.self, forKey: .phone)
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
                            is: .count(5 ... 5),
                            required: true)
            validations.add("address",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("sub_district",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("district",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("province",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("country",
                            as: String.self,
                            is: .count(1 ... 300),
                            required: true)
            validations.add("phone",
                            as: String.self,
                            is: .count(10 ... 10),
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
