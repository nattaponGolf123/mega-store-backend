import Foundation
import Vapor
import Fluent

struct ContactInformation: Content {
    var contactPerson: String
    var phone: String
    var email: String
    
    init(contactPerson: String = "",
         phone: String = "",
         email: String = "") {
        self.contactPerson = contactPerson
        self.phone = phone
        self.email = email
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contactPerson = (try? container.decode(String.self,
                                                    forKey: .contactPerson)) ?? ""
        self.phone = (try? container.decode(String.self,
                                                  forKey: .phone)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contactPerson, forKey: .contactPerson)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
    }
    
    enum CodingKeys: String, CodingKey {
        case contactPerson = "contact_person"
        case phone = "phone_number"
        case email
    }
}

extension ContactInformation: Equatable {
    static func == (lhs: ContactInformation,
                    rhs: ContactInformation) -> Bool {
        lhs.contactPerson == rhs.contactPerson &&
            lhs.phone == rhs.phone &&
            lhs.email == rhs.email
    }
}

extension ContactInformation {
    struct Stub {
        static var john: ContactInformation {
            ContactInformation(contactPerson: "John Doe",
                               phone: "1234567890",
                               email: "john@email.com")
        }
        
        static var jane: ContactInformation {
            ContactInformation(contactPerson: "Jane Doe",
                               phone: "0987654321",
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
