import Foundation
import Vapor

struct ContactGroupRequest {

    struct FetchAll: Content {
        let showDeleted: Bool
        let sortBy: SortBy
        let sortOrder: SortOrder

        static let minPageRange: (min: Int, max: Int) = (1, .max)
        static let perPageRange: (min: Int, max: Int) = (20, 1000)

        init(
            showDeleted: Bool = false,
            sortBy: SortBy = .createdAt,
            sortOrder: SortOrder = .asc
        ) {
            self.showDeleted = showDeleted
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted =
                (try? container.decodeIfPresent(Bool.self, forKey: .showDeleted)) ?? false
            self.sortBy =
                (try? container.decodeIfPresent(SortBy.self, forKey: .sortBy)) ?? .createdAt
            self.sortOrder =
                (try? container.decodeIfPresent(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }

    struct Search: Content, Validatable {
        let query: String
        let sortBy: SortBy
        let sortOrder: SortOrder

        init(
            query: String,
            sortBy: SortBy = .createdAt,
            sortOrder: SortOrder = .asc
        ) {
            self.query = query
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.query = try container.decode(String.self, forKey: .query)
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .createdAt
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(query, forKey: .query)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

        enum CodingKeys: String, CodingKey {
            case query = "q"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "q", as: String.self,
                is: .count(1...200),
                required: true)
        }
    }

    struct Create: Content, Validatable {
        let name: String
        let description: String?

        init(
            name: String,
            description: String? = nil
        ) {
            self.name = name
            self.description = description
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(
                String.self,
                forKey: .name)
            self.description = try? container.decode(
                String.self,
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
            validations.add(
                "name", as: String.self,
                is: .count(3...200),
                required: true)
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let description: String?

        init(
            name: String? = nil,
            description: String? = nil
        ) {
            self.name = name
            self.description = description
        }

        enum CodingKeys: String, CodingKey {
            case name
            case description
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "name", as: String.self,
                is: .count(3...200),
                required: false)
        }
    }

    struct AddContacts: Content, Validatable {
        let contactIds: [UUID]

        init(contactIds: [UUID]) {
            self.contactIds = contactIds
        }

        enum CodingKeys: String, CodingKey {
            case contactIds = "contact_ids"
        }

        static func validations(_ validations: inout Validations) {
            validations.add(
                "contact_ids", as: [UUID].self,
                required: true)
        }
    }
}
