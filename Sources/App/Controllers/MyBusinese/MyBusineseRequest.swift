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
        
        init(name: String,
             vatRegistered: Bool = false,
             contactInformation: ContactInformation? = nil,
             taxNumber: String,
             legalStatus: BusinessType = .individual,
             website: String? = nil,
             note: String? = nil) {
            self.name = name
            self.vatRegistered = vatRegistered
            self.contactInformation = contactInformation
            self.taxNumber = taxNumber
            self.legalStatus = legalStatus
            self.website = website
            self.note = note
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: true)
            validations.add("tax_number", 
                            as: String.self,
                            is: .count(13...13),
                            required: true)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website 
            case note
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

}
