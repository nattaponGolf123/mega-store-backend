import Foundation
import Vapor

struct ContactGroupRequest {    

    struct Create: Content, Validatable {
        let name: String
        let description: String?
        
        init(name: String,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                    forKey: .description)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
        }
                
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: true)
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        
        init(name: String? = nil,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200),
                            required: false)
        }
    }
}

//extension ContactGroupRequest {
//    enum SortBy: String, Sortable {
//        case name
//        case createdAt = "created_at"
//        
//        static func == (lhs: Self, rhs: Self) -> Bool {
//            return lhs.rawValue == rhs.rawValue
//        }
//    }
//
//}
