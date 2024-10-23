import Foundation

struct ShippingAddress: Codable {
    let id: UUID
    var address: String
    var subDistrict: String
    var district: String
    var province: String
    var country: String
    
    @ThailandPostCode
    var postalCode: String
    
    var phone: String
    
    init(id: UUID = .init(),
         address: String = "",
         subDistrict: String = "",
         district: String = "",
         province: String = "",
         country: String = "THA",
         postalCode: String = "00000",
         phone: String = "") {
        self.id = id
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
        self.id = try container.decode(UUID.self, forKey: .id)
        self.address = (try? container.decode(String.self,
                                              forKey: .address)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                                  forKey: .subDistrict)) ?? ""
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
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(district, forKey: .district)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phone, forKey: .phone)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
        case subDistrict = "sub_district"
        case district
        case province
        case postalCode = "postal_code"
        case country
        case phone
    }
}

extension ShippingAddress: Equatable {
    static func == (lhs: ShippingAddress, rhs: ShippingAddress) -> Bool {
        lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.subDistrict == rhs.subDistrict &&
            lhs.district == rhs.district &&
            lhs.province == rhs.province &&
            lhs.country == rhs.country &&
            lhs.postalCode == rhs.postalCode &&
            lhs.phone == rhs.phone
    }
}

extension ShippingAddress {
    struct Stub {
        static var home: ShippingAddress {
            ShippingAddress(address: "123",
                            subDistrict: "123",
                            district: "Bangkok",
                            province: "ddd",
                            country: "Thailand",
                            postalCode: "12022",
                            phone: "123-456-7890")
        }
    }
}

