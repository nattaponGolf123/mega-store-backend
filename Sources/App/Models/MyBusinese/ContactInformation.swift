import Foundation
import Vapor
import Fluent

struct ContactInformation: Content {
        var contactPerson: String
        var phoneNumber: String        
        var email: String
        var address: String

        init(contactPerson: String,
             phoneNumber: String = "",
             email: String = "",
             address: String = "") {
            self.contactPerson = contactPerson
            self.phoneNumber = phoneNumber
            self.email = email
            self.address = address
        }

        //decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.contactPerson = try container.decode(String.self,
                                                    forKey: .contactPerson)
            self.phoneNumber = try container.decode(String.self,
                                                   forKey: .phoneNumber)
            self.email = try container.decode(String.self,
                                             forKey: .email)
            self.address = try container.decode(String.self,
                                              forKey: .address)
        }

        //encode
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contactPerson, forKey: .contactPerson)
            try container.encode(phoneNumber, forKey: .phoneNumber)
            try container.encode(email, forKey: .email)
            try container.encode(address, forKey: .address)
        }

        enum CodingKeys: String, CodingKey {
            case contactPerson = "contact_person"
            case phoneNumber = "phone_number"
            case email
            case address
        }
}
