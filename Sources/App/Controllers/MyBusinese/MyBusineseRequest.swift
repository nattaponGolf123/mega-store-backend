import Foundation
import Vapor
import Fluent
import FluentMongoDriver

struct MyBusinessRequest {
    
    typealias UpdateShippingAddress = ContactRequest.UpdateShippingAddress
    typealias UpdateBusinessAddress = ContactRequest.UpdateBusinessAddress
    typealias CreateShippingAddress = ContactRequest.CreateShippingAddress
    typealias CreateBusineseAddress = ContactRequest.CreateBusinessAddress
    
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        
        let businessAddress: CreateBusineseAddress?
        let shippingAddress: CreateShippingAddress?
        
        init(name: String,
             vatRegistered: Bool = false,
             contactInformation: ContactInformation? = nil,
             taxNumber: String,
             legalStatus: BusinessType = .individual,
             website: String? = nil,
             note: String? = nil,
             businessAddress: CreateBusineseAddress? = nil,
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

//            validations.add("business_address", as: CreateBusineseAddress?.self, required: false) { businessAddressValidations in
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

    struct UpdateBusinessAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: UpdateBusinessAddress
    }
    
    struct UpdateShippingAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: UpdateShippingAddress
    }
}
