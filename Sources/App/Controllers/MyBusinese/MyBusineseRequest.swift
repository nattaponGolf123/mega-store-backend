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

//    struct UpdateBussineseAddress: Content, Validatable {                
//        let address: String?
//        let branch: String?
//        let branchCode: String?
//        let subDistrict: String?  
//        let city: String?
//        let province: String?
//        let country: String?
//
//        //@ThailandPostCode
//        let postalCode: String?
//
//        let phone: String?
//        let email: String?
//        let fax: String?
//        
//        static func validations(_ validations: inout Validations) {
////            if let postalCode {
////                validations.add("postal_code", as: String.self,
////                                is: .count(5...5))
////            }
//
//        //     validations.add("address", as: String.self,
//        //                     is: .count(1...200))
//        //     validations.add("postalCode", as: String.self,
//        //                     is: .count(5...5))        
//        }
//
//        enum CodingKeys: String, CodingKey {            
//            case branch
//            case branchCode = "branch_code"
//            case address
//            case subDistrict = "sub_district"
//            case city
//            case province
//            case postalCode = "postal_code"
//            case country
//            case phone 
//            case email
//            case fax
//        }
//    }
//
//    struct UpdateShippingAddress: Content, Validatable {
//        let address: String?        
//        let subDistrict: String?
//        let city: String?
//        let province: String?
//        let country: String?
//
//        //@ThailandPostCode
//        let postalCode: String?
//
//        let phone: String?
//        
//        static func validations(_ validations: inout Validations) {
////            if let postalCode {
////                validations.add("postal_code", as: String.self,
////                                is: .count(5...5))
////            }
////
////            if let address {
////                validations.add("address", as: String.self,
////                                is: .count(1...200))
////            }
//
//        //     validations.add("address", as: String.self,
//        //                     is: .count(1...200))
//        //     validations.add("postalCode", as: String.self,
//        //                     is: .count(5...5))        
//        }
//
//        enum CodingKeys: String, CodingKey {
//            case address
//            case subDistrict = "sub_district"
//            case city
//            case province
//            case postalCode = "postal_code"
//            case country
//            case phone
//        }
//    }
}
