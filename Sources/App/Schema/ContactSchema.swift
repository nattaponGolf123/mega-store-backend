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
            //.field("group_id", .uuid)//.references(CustomerGroup.schema, "id"))
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
    
    @Field(key: "group_id")
    var groupId: UUID?
    
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
    var website: String?
    
    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]
    
    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int
    
    @Field(key: "note")
    var note: String?
    
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
         groupId: UUID? = nil,
         kind: ContactKind = .both,
         vatRegistered: Bool = false,
         contactInformation: ContactInformation = .init(),
         taxNumber: String = "",
         legalStatus: BusinessType = .individual,
         website: String? = nil,
         businessAddress: [BusinessAddress] = [.init()],
         shippingAddress: [ShippingAddress] = [.init()],
         paymentTermsDays: Int = 30,
         note: String? = nil) {
        
        self.id = id ?? UUID()
        self.code = ContactCode(number: number).code
        self.groupId = groupId
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

extension Contact {
    struct Stub {
        static var customer: Contact {
            Contact(name: "ABC Company",
                    kind: .customer,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .individual,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
        static var supplier: Contact {
            Contact(name: "ABC Industries",
                    kind: .supplier,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .companyLimited,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(branch: "HQ",
                                                      branchCode: "00001",
                                                      address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
        static var both: Contact {
            Contact(name: "ABC Industries",
                    kind: .both,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .companyLimited,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(branch: "HQ",
                                                      branchCode: "00001",
                                                      address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
    }
}
*/