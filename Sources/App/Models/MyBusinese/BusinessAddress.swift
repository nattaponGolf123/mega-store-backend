import Foundation
import Vapor
import Fluent

struct BusinessAddress: Content {
    var address: String
    var branch: String
    var city: String
    var postalCode: String
    var country: String
    var phoneNumber: String
    var email: String
    var fax: String
    
    init(address: String,
         branch: String,
         city: String,
         postalCode: String,
         country: String,
         phoneNumber: String = "",
         email: String = "",
         fax: String = "") {
        self.address = address
        self.branch = branch
        self.city = city
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.fax = fax
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self,
                                            forKey: .address)
        self.branch = try container.decode(String.self,
                                           forKey: .branch)
        self.city = try container.decode(String.self,
                                         forKey: .city)
        self.postalCode = try container.decode(String.self,
                                               forKey: .postalCode)
        self.country = try container.decode(String.self,
                                            forKey: .country)
        self.phoneNumber = try container.decode(String.self,
                                                forKey: .phoneNumber)
        self.email = try container.decode(String.self,
                                          forKey: .email)
        self.fax = try container.decode(String.self,
                                        forKey: .fax)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(branch, forKey: .branch)
        try container.encode(city, forKey: .city)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case branch
        case city
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
                            city: "New York",
                            postalCode: "10001",
                            country: "USA",
                            phoneNumber: "1234567890",
                            email: "",
                            fax: "")
        }
    }
}