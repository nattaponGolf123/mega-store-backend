import Foundation
import Vapor
import Fluent

struct BusinessAddress: Content {
    
    var id: UUID    
    var branch: String  
    var branchCode: String

    var address: String
    var subDistrict: String  
    var district: String
    var province: String
    var country: String
    
    @ThailandPostCode
    var postalCode: String

    var phone: String
    var email: String
    var fax: String
    
    init(id: UUID = UUID(),
         branch: String = "",
         branchCode: String = "",
         address: String = "",         
         subDistrict: String = "",
         district: String = "",
         province: String = "",
         postalCode: String = "00000",
         country: String = "THA",
         phone: String = "",
         email: String = "",
         fax: String = "") {
        self.id = id
        self.branch = branch
        self.branchCode = branchCode
        self.address = address        
        self.subDistrict = subDistrict
        self.district = district
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.phone = phone
        self.email = email
        self.fax = fax
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self,
                                       forKey: .id)
        self.branch = (try? container.decode(String.self,
                                           forKey: .branch)) ?? ""
        self.branchCode = (try? container.decode(String.self,
                                             forKey: .branchCode)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                            forKey: .subDistrict)) ?? ""
        self.address = (try? container.decode(String.self,
                                            forKey: .address)) ?? ""                                                       
        self.district = (try? container.decode(String.self,
                                         forKey: .district)) ?? ""
        self.province = (try? container.decode(String.self,
                                             forKey: .province)) ?? ""
        self.postalCode = (try? container.decode(String.self,
                                               forKey: .postalCode)) ?? ""
        self.country = (try? container.decode(String.self,
                                            forKey: .country)) ?? ""
        self.phone = (try? container.decode(String.self,
                                                forKey: .phone)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
        self.fax = (try? container.decode(String.self,
                                            forKey: .fax)) ?? ""                                            

    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(branch, forKey: .branch)
        try container.encode(branchCode, forKey: .branchCode)
        try container.encode(address, forKey: .address)        
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(district, forKey: .district)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }
    
    enum CodingKeys: String, CodingKey {
        case id        
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

extension BusinessAddress {
    struct Stub {
        static var usa: BusinessAddress {
            BusinessAddress(branch: "Head Quarter",
                            branchCode: "00001",
                            address: "123 Main St",                            
                            subDistrict: "123",
                            district: "New York",
                            province: "NY",
                            postalCode: "10001",
                            country: "USA",
                            phone: "1234567890",
                            email: "",
                            fax: "")
        }
    }
}
