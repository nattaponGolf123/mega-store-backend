import Foundation
import Vapor
import Fluent
import FluentMongoDriver

struct MyBusineseRequest {
    
    typealias UpdateShippingAddress = ContactRequest.UpdateShippingAddress
    typealias UpdateBussineseAddress = ContactRequest.UpdateBussineseAddress
    
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        
        let businessAddress: CreateBussineseAddress?
        let shippingAddress: CreateShippingAddress?
        
        init(name: String,
             vatRegistered: Bool = false,
             contactInformation: ContactInformation? = nil,
             taxNumber: String,
             legalStatus: BusinessType = .individual,
             website: String? = nil,
             note: String? = nil,
             businessAddress: CreateBussineseAddress? = nil,
             shippingAddress: CreateShippingAddress? = nil) {
            self.name = name
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
            self.businessAddress = businessAddress
            self.shippingAddress = shippingAddress
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: true)
            validations.add("tax_number",
                            as: String.self,
                            is: .count(13...13),
                            required: true)

//            validations.add("business_address", as: CreateBussineseAddress?.self, required: false) { businessAddressValidations in
//                businessAddressValidations.add("address", as: String.self, is: .count(1...300), required: true)
//                businessAddressValidations.add("sub_district", as: String.self, is: .count(1...300), required: true)
//                businessAddressValidations.add("district", as: String.self, is: .count(1...300), required: true)
//                businessAddressValidations.add("province", as: String.self, is: .count(1...300), required: true)
//                businessAddressValidations.add("postal_code", as: String.self, is: .count(5...5), required: true)
//                businessAddressValidations.add("country", as: String.self, is: .count(1...300), required: true)
//                businessAddressValidations.add("phone", as: String.self, is: .count(10...10), required: false)
//                businessAddressValidations.add("email", as: String.self, is: .email, required: false)
//                businessAddressValidations.add("fax", as: String.self, is: .count(10...10), required: false)
//            }
//
//            validations.add("shipping_address", as: CreateShippingAddress?.self, required: false) { shippingAddressValidations in
//                shippingAddressValidations.add("address", as: String.self, is: .count(1...300), required: true)
//                shippingAddressValidations.add("sub_district", as: String.self, is: .count(1...300), required: true)
//                shippingAddressValidations.add("district", as: String.self, is: .count(1...300), required: true)
//                shippingAddressValidations.add("province", as: String.self, is: .count(1...300), required: true)
//                shippingAddressValidations.add("postal_code", as: String.self, is: .count(5...5), required: true)
//                shippingAddressValidations.add("country", as: String.self, is: .count(1...300), required: true)
//                shippingAddressValidations.add("phone", as: String.self, is: .count(10...10), required: false)
//            }
        }

        enum CodingKeys: String, CodingKey {
            case name
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case businessAddress = "business_address"
            case shippingAddress = "shipping_address"
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?
        let logo: String?
        let stampLogo: String?
        let authorizedSignSignature: String?
        let note: String?
        
        init(name: String? = nil,
             vatRegistered: Bool? = nil,
             contactInformation: ContactInformation? = nil,
             taxNumber: String? = nil,
             legalStatus: BusinessType? = nil,
             website: String? = nil,
             logo: String? = nil,
             stampLogo: String? = nil,
             authorizedSignSignature: String? = nil,
             note: String? = nil) {
            self.name = name
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.logo = logo
            self.stampLogo = stampLogo
            self.authorizedSignSignature = authorizedSignSignature
            self.note = note
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case logo
            case stampLogo = "stamp_logo"
            case authorizedSignSignature = "authorized_sign_signature"
            case note
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: false)
            validations.add("tax_number",
                            as: String.self,
                            is: .count(13...13),
                            required: false)
        }
    }

    struct UpdateBusineseAdressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: UpdateBussineseAddress
    }
    
    struct UpdateShippingAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: UpdateShippingAddress
    }
    
    struct CreateBussineseAddress: Content, Validatable  {
        let address: String
        let subDistrict: String
        let district: String
        let province: String
        let country: String
        let postalCode: String
        
        let phone: String?
        let fax: String?
        let email: String?
        
        init(address: String,
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
            self.phone = phone
            self.fax = fax
            self.email = email
        }
        
        func toBusinessAddress() -> BusinessAddress {
            return BusinessAddress(address: address,
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
