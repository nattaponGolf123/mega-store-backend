import Foundation
import Vapor
import Fluent

struct ContactSchema {
    static var schema: String { Contact.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("code", .string, .required)
            .unique(on: "code")
            .field("kind", .string, .required)
            .field("name", .string, .required)
            .field("vat_registered", .bool, .required)
            .field("contact_information", .json, .required)
            .field("tax_number", .string, .required)
            .unique(on: "tax_number")
            .field("legal_status", .string, .required)
            .field("website", .string)
            .field("business_address", .json, .required)
            .field("shipping_address", .json, .required)
            .field("payment_terms_days", .int)
            .field("note", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)            
    }
    
}

/*

enum ContactKind: String, Codable {
    case customer = "CUSTOMER"
    case supplier = "SUPPLIER"
    case both = "BOTH"
}

final class Contact: Model, Content {
    static let schema = "Contacts"

    @ID(key: .id)
    var id: UUID?
        
    @Field(key: "code")
    var code: String
    
    @Field(key: "kind")
    var kind: ContactKind

    @Field(key: "name")
    var name: String

     @Field(key: "vat_registered")
    var vatRegistered: Bool

    @Field(key: "contact_information")
    var contactInformation: ContactInformation

    @Field(key: "tax_number")
    var taxNumber: String

    @Enum(key: "legal_status")
    var legalStatus: BusinessType

    @Field(key: "website")
    var website: String

    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]

    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int

    @Field(key: "note")
    var note: String

    @Timestamp(key: "created_at", 
               on: .create, 
               format: .iso8601)
    var createdAt: Date?

    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", 
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil,
         number: Int = 1,         
         name: String = "",
         kind: ContactKind = .both,
         vatRegistered: Bool = false,
         contactInformation: ContactInformation = .init(),
         taxNumber: String = "",
         legalStatus: BusinessType = .individual,
         website: String? = "",
         businessAddress: [BusinessAddress] = [.init()],
         shippingAddress: [ShippingAddress] = [.init()],
         paymentTermsDays: Int = 30,
         note: String = "") {

        self.id = id ?? UUID()
        self.code = ContactCode(number: number).code
        self.name = name
        self.vatRegistered = vatRegistered
        self.contactInformation = contactInformation
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.shippingAddress = shippingAddress
        self.paymentTermsDays = paymentTermsDays
        self.note = note
    }

}
*/