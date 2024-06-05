import Foundation
import Vapor
import Fluent

struct ContactInformation: Content {
        var contactPerson: String
        var phoneNumber: String        
        var email: String

        init(contactPerson: String,
             phoneNumber: String = "",
             email: String = "") {
            self.contactPerson = contactPerson
            self.phoneNumber = phoneNumber
            self.email = email
        }

        //decode
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.contactPerson = (try? container.decode(String.self,
                                                    forKey: .contactPerson)) ?? ""
            self.phoneNumber = (try? container.decode(String.self,
                                                   forKey: .phoneNumber)) ?? ""
            self.email = (try? container.decode(String.self,
                                             forKey: .email)) ?? ""
        }

        //encode
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contactPerson, forKey: .contactPerson)
            try container.encode(phoneNumber, forKey: .phoneNumber)
            try container.encode(email, forKey: .email)
        }

        enum CodingKeys: String, CodingKey {
            case contactPerson = "contact_person"
            case phoneNumber = "phone_number"
            case email
        }
}

extension ContactInformation {
    struct Stub {
        static var john: ContactInformation {
            ContactInformation(contactPerson: "John Doe",
                                phoneNumber: "1234567890",
                                email: "john@email.com")
        }

        static var jane: ContactInformation {
            ContactInformation(contactPerson: "Jane Doe",
                                phoneNumber: "0987654321",
                                email: "")
        }
    }
}


/*
//json response preview
{
    "contact_person": "John Doe",
    "phone_number": "1234567890",
    "email": "",
    "address": "1234 Main St"
}
*/