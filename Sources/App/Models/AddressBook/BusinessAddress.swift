import Foundation
import Vapor
import Fluent

struct BusinessAddress: Content {
    let address: String
    let branch: String  
    let subDistrict: String  
    let city: String
    let province: String
    let country: String
    
    @ThailandPostCode
    var postalCode: String

    let phoneNumber: String
    let email: String
    let fax: String
    
    init(address: String,
         branch: String,
         subDistrict: String,
         city: String,
         province: String,
         postalCode: String,
         country: String = "THA",
         phoneNumber: String = "",
         email: String = "",
         fax: String = "") {
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

extension BusinessAddress {
    struct Stub {
        static var usa: BusinessAddress {
            BusinessAddress(address: "123 Main St",
                            branch: "Main",
                            subDistrict: "123",
                            city: "New York",
                            province: "NY",
                            postalCode: "10001",
                            country: "USA",
                            phoneNumber: "1234567890",
                            email: "",
                            fax: "")
        }
    }
}
