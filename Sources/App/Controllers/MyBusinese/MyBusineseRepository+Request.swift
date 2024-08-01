import Foundation
import Vapor
import Fluent
import FluentMongoDriver

extension MyBusineseRepository {

    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String?        
        let note: String?
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("tax_number", as: String.self,
                            is: .count(13...13))
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
//            if let name {
//                validations.add("name", as: String.self,
//                                is: .count(3...200))
//            }
//
//            if let taxNumber {
//                validations.add("tax_number", as: String.self,
//                                is: .count(13...13))
//            }
        //     validations.add("name", as: String.self,
        //                     is: .count(3...200))
        //     validations.add("taxNumber", as: String.self,
        //                     is: .count(13...13))
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

        //@ThailandPostCode
        let postalCode: String?

        let phone: String?
        let email: String?
        let fax: String?
        
        static func validations(_ validations: inout Validations) {
//            if let postalCode {
//                validations.add("postal_code", as: String.self,
//                                is: .count(5...5))
//            }

        //     validations.add("address", as: String.self,
        //                     is: .count(1...200))
        //     validations.add("postalCode", as: String.self,
        //                     is: .count(5...5))        
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

        //@ThailandPostCode
        let postalCode: String?

        let phone: String?
        
        static func validations(_ validations: inout Validations) {
//            if let postalCode {
//                validations.add("postal_code", as: String.self,
//                                is: .count(5...5))
//            }
//
//            if let address {
//                validations.add("address", as: String.self,
//                                is: .count(1...200))
//            }

        //     validations.add("address", as: String.self,
        //                     is: .count(1...200))
        //     validations.add("postalCode", as: String.self,
        //                     is: .count(5...5))        
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
}

/*

struct BusinessAddress: Content {
    
    let id: UUID
    let address: String
    let branch: String  
    let subDistrict: String  
    let city: String
    let province: String
    let country: String
    
    @ThailandPostCode
    var postalCode: String

    let phone: String
    let email: String
    let fax: String
    
    init(id: UUID = UUID(),
         address: String,
         branch: String,
         subDistrict: String,
         city: String,
         province: String,
         postalCode: String,
         country: String = "THA",
         phone: String = "",
         email: String = "",
         fax: String = "") {
        self.id = id
        self.address = address
        self.branch = branch
        self.subDistrict = subDistrict
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.fax = fax
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self,
                                       forKey: .id)
        self.address = (try? container.decode(String.self,
                                            forKey: .address)) ?? ""
        self.branch = (try? container.decode(String.self,
                                           forKey: .branch)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                               forKey: .subDistrict)) ?? ""
        self.city = (try? container.decode(String.self,
                                         forKey: .city)) ?? ""
        self.province = (try? container.decode(String.self,
                                             forKey: .province)) ?? ""
        self.postalCode = (try? container.decode(String.self,
                                               forKey: .postalCode)) ?? ""
        self.country = (try? container.decode(String.self,
                                            forKey: .country)) ?? ""
        self.phoneNumber = (try? container.decode(String.self,
                                                forKey: .phoneNumber)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
        self.fax = (try? container.decode(String.self,
                                            forKey: .fax)) ?? ""                                            

    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(branch, forKey: .branch)
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(city, forKey: .city)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
        case branch
        case subDistrict = "sub_district"
        case city
        case province
        case postalCode = "postal_code"
        case country
        case phoneNumber = "phone_number"
        case email
        case fax
    }
}*/

/*
struct ShippingAddress: Codable {
    let id: UUID
    let address: String
    let branch: String
    let subDistrict: String
    let city: String
    let province: String
    let country: String

    @ThailandPostCode
    var postalCode: String

    let phone: String
    let email: String
    let fax: String

    init(id: UUID = .init(),
         address: String,
         branch: String,
         subDistrict: String,
         city: String,
         province: String,
         country: String = "THA",
         postalCode: String,
         phone: String = "",
         email: String = "",
         fax: String = "") {
        self.id = id
        self.address = address
        self.branch = branch
        self.subDistrict = subDistrict
        self.city = city
        self.province = province
        self.country = country
        self.postalCode = postalCode
        self.phoneNumber = phoneNumber
        self.email = email
        self.fax = fax
    }

    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.address = (try? container.decode(String.self,
                                            forKey: .address)) ?? ""
        self.branch = (try? container.decode(String.self,
                                             forKey: .branch)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                                 forKey: .subDistrict)) ?? ""
        self.city = (try? container.decode(String.self,
                                             forKey: .city)) ?? ""
        self.province = (try? container.decode(String.self,
                                                 forKey: .province)) ?? ""
        self.postalCode = (try? container.decode(String.self,
                                                    forKey: .postalCode)) ?? ""
        self.country = (try? container.decode(String.self,
                                                forKey: .country)) ?? ""
        self.phoneNumber = (try? container.decode(String.self,
                                                    forKey: .phoneNumber)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
        self.fax = (try? container.decode(String.self,
                                            forKey: .fax)) ?? ""                                                    
    }

    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(branch, forKey: .branch)
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(city, forKey: .city)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case address
        case branch
        case subDistrict = "sub_district"
        case city
        case province
        case postalCode = "postal_code"
        case country
        case phoneNumber = "phone_number"
        case email
        case fax
    }
}

*/
