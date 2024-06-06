import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ContactRepositoryProtocol {
    func fetchAll(req: ContactRepository.Fetch, on db: Database) async throws -> PaginatedResponse<Contact>
    func create(with content: ContactRepository.Create, on db: Database) async throws -> Contact
    func find(id: UUID, on db: Database) async throws -> Contact
    func update(id: UUID, with content: ContactRepository.Update, on db: Database) async throws -> Contact
    func delete(id: UUID, on db: Database) async throws -> Contact
    func updateBussineseAddress(id: UUID, addressID: UUID, with content: ContactRepository.UpdateBussineseAddress, on db: Database) async throws -> Contact
    func updateShippingAddress(id: UUID, addressID: UUID, with content: ContactRepository.UpdateShippingAddress, on db: Database) async throws -> Contact
    func search(req: ContactRepository.Search, on db: Database) async throws -> PaginatedResponse<Contact>
    func fetchLastedCode(on db: Database) async throws -> Int
}

class ContactRepository: ContactRepositoryProtocol {
    
    func fetchAll(req: Fetch, on db: any Database) async throws -> PaginatedResponse<Contact> {
        
        let page = req.page
        let perPage = req.perPage
        
        guard
            page > 0,
            perPage > 0
        else { throw DefaultError.invalidInput }
        
        let query = Contact.query(on: db)
        
        if req.showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }
        
        let total = try await query.count()
        let items = try await query.range((page - 1) * perPage..<(page * perPage)).all()
        
        let response = PaginatedResponse(page: page,
                                         perPage: perPage,
                                         total: total,
                                         items: items)
        
        return response
    }
    
    func create(with content: ContactRepository.Create, on db: Database) async throws -> Contact {

        // check and prevent duplicate tax id
        guard
            try await Contact.query(on: db).filter(\.$taxNumber == content.taxNumber).count() == 0
        else { throw CommonError.duplicateTaxNumber }

        let lastedRunningNumber = try await fetchLastedCode(on: db)
        let nextNumber = lastedRunningNumber + 1

        let newContact = Contact(number: nextNumber, 
                                 name: content.name,
                                 groupId: content.groupId,
                                 vatRegistered: content.vatRegistered,
                                 contactInformation: content.contactInformation ?? .init(),
                                 taxNumber: content.taxNumber,
                                 legalStatus: content.legalStatus,
                                 website: content.website,
                                 businessAddress: [.init()],
                                 shippingAddress: [.init()],
                                 paymentTermsDays: content.paymentTermsDays ?? 30,
                                 note: content.note)
        do {
            print(newContact)
            try await newContact.save(on: db)
        } catch {
            print(error)
            throw DefaultError.error(message: error.localizedDescription)
        }
        
        return newContact
    }
    
    func find(id: UUID, on db: Database) async throws -> Contact {
        guard let contact = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
        return contact
    }
    
    func update(id: UUID, with content: ContactRepository.Update, on db: Database) async throws -> Contact {
        guard let contact = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
        if let name = content.name {                        
            contact.name = name
        }
        
        if let vatRegistered = content.vatRegistered {
            contact.vatRegistered = vatRegistered
        }
        
        if let contactInformation = content.contactInformation {
            contact.contactInformation = contactInformation
        }
        
        if let taxNumber = content.taxNumber {            
            guard
                try await Contact.query(on: db).filter(\.$taxNumber == taxNumber).count() == 0
            else { throw CommonError.duplicateTaxNumber }

            contact.taxNumber = taxNumber
        }
        
        if let legalStatus = content.legalStatus {
            contact.legalStatus = legalStatus
        }
        
        if let website = content.website {
            contact.website = website
        }
        
        if let note = content.note {
            contact.note = note
        }
        
        if let groupId = content.groupId {
            contact.groupId = groupId
        }
        
        if let paymentTermsDays = content.paymentTermsDays {
            contact.paymentTermsDays = paymentTermsDays
        }
        
        try await contact.save(on: db)
        return contact
    }
    
    func updateBussineseAddress(id: UUID, addressID: UUID , with content: ContactRepository.UpdateBussineseAddress, on db: Database) async throws -> Contact {
        guard
            let Contact = try await Contact.find(id, on: db),
            var addr = Contact.businessAddress.first(where: { $0.id == addressID })
        else { throw DefaultError.notFound }
        
        if let address = content.address {
            addr.address = address
        }
        
        if let branch = content.branch {
            addr.branch = branch
        }
        
        if let branchCode = content.branchCode {
            addr.branchCode = branchCode
        }
        
        if let subDistrict = content.subDistrict {
            addr.subDistrict = subDistrict
        }
        
        if let city = content.city {
            addr.city = city
        }
        
        if let province = content.province {
            addr.province = province
        }
        
        if let postalCode = content.postalCode {
            addr.postalCode = postalCode
        }
        
        if let country = content.country {
            addr.country = country
        }
        
        if let phone = content.phone {
            addr.phone = phone
        }
        
        if let email = content.email {
            addr.email = email
        }
        
        if let fax = content.fax {
            addr.fax = fax
        }
        Contact.businessAddress = [addr]
        
        try await Contact.save(on: db)
        return Contact
    }
    
    func updateShippingAddress(id: UUID, addressID: UUID, with content: ContactRepository.UpdateShippingAddress, on db: Database) async throws -> Contact {
        guard
            let Contact = try await Contact.find(id, on: db),
            var addr = Contact.shippingAddress.first(where: { $0.id == addressID })
        else { throw DefaultError.notFound }
        
        if let address = content.address {
            addr.address = address
        }
        
        if let subDistrict = content.subDistrict {
            addr.subDistrict = subDistrict
        }
        
        if let city = content.city {
            addr.city = city
        }
        
        if let province = content.province {
            addr.province = province
        }
        
        if let postalCode = content.postalCode {
            addr.postalCode = postalCode
        }
        
        if let country = content.country {
            addr.country = country
        }
        
        if let phone = content.phone {
            addr.phone = phone
        }
        
        Contact.shippingAddress = [addr]
        
        try await Contact.save(on: db)
        return Contact
    }
    
    func delete(id: UUID, on db: Database) async throws -> Contact {
        guard let contact = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
        try await contact.delete(on: db)
        return contact
    }
    
    func search(req: ContactRepository.Search, on db: Database) async throws -> PaginatedResponse<Contact> {
        do {
            let perPage = req.perPage
            let page = req.page
            let keyword = req.q
            
            guard
                keyword.count > 0,
                perPage > 0,
                page > 0
            else { throw DefaultError.invalidInput }
            
            //let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
            //let query = Contact.query(on: db).filter(\.$name =~ regexPattern)

            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
            let query = Contact.query(on: db).group(.or) { or in

                or.filter(\.$name =~ regexPattern)
                or.filter(\.$code =~ regexPattern)
//                or.filter(\.$contactInformation.contactPerson =~ regexPattern)
//                or.filter(\.$contactInformation.phoneNumber =~ regexPattern)
//                or.filter(\.$contactInformation.email =~ regexPattern)
                or.filter(\.$taxNumber =~ regexPattern)
                or.filter(\.$website =~ regexPattern)
                or.filter(\.$note =~ regexPattern)                
             }
        
            
            let total = try await query.count()
            let items = try await query.range((page - 1) * perPage..<(page * perPage)).all()
            
            
            let response = PaginatedResponse(page: page,
                                             perPage: perPage,
                                             total: total,
                                             items: items)
            
            return response
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    //  fetch contact.code which is "C00001" , "C" is prefix and "00001" is number then return max of number
    func fetchLastedCode(on db: Database) async throws -> Int {
        let query = Contact.query(on: db).withDeleted()
        query.sort(\.$code, .descending)
        query.limit(1)

        let contact = try await query.first()
        let number = ContactCode.getNumber(from: contact?.code ?? "")

        return number ?? 0
    }

}


extension ContactRepository {
    
    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        
        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20) {
            self.showDeleted = showDeleted
            self.page = page
            self.perPage = perPage
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }
        
        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page = "page"
            case perPage = "per_page"
        }
    }
    
    struct Search: Content {
        let q: String
        let page: Int
        let perPage: Int
        
        init(q: String,
             page: Int = 1,
             perPage: Int = 20) {
            self.q = q
            self.page = page
            self.perPage = perPage
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.q = try container.decode(String.self, forKey: .query)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(q, forKey: .query)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }
        
        enum CodingKeys: String, CodingKey {
            case query = "q"
            case page = "page"
            case perPage = "per_page"
        }
    }
    
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String?
        let note: String?
        let groupId: UUID?
        let paymentTermsDays: Int?
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("tax_number", as: String.self,
                            is: .count(13...13))
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case groupId = "group_id"
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website
            case note
            case paymentTermsDays = "payment_terms_days"
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?
        let note: String?
        let paymentTermsDays: Int?
        let groupId: UUID?
        
        static func validations(_ validations: inout Validations) {
            //            if let name {
            //                validations.add("name", as: String.self,
            //                                is: .count(3...200))
            //            }
            //
            //            if let taxNumber {
            //                validations.add("tax_number", as: String.self,
            //                                is: .count(13...13))
            //            }
            //     validations.add("name", as: String.self,
            //                     is: .count(3...200))
            //     validations.add("taxNumber", as: String.self,
            //                     is: .count(13...13))
        }
    }
    
    struct UpdateBussineseAddress: Content, Validatable {
        let address: String?
        let branch: String?
        let branchCode: String?
        let subDistrict: String?
        let city: String?
        let province: String?
        let country: String?
        
        //@ThailandPostCode
        let postalCode: String?
        
        let phone: String?
        let email: String?
        let fax: String?
        
        static func validations(_ validations: inout Validations) {
            //            if let postalCode {
            //                validations.add("postal_code", as: String.self,
            //                                is: .count(5...5))
            //            }
            
            //     validations.add("address", as: String.self,
            //                     is: .count(1...200))
            //     validations.add("postalCode", as: String.self,
            //                     is: .count(5...5))
        }
        
        enum CodingKeys: String, CodingKey {
            case branch
            case branchCode = "branch_code"
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone
            case email
            case fax
        }
    }
    
    struct UpdateShippingAddress: Content, Validatable {
        let address: String?
        let subDistrict: String?
        let city: String?
        let province: String?
        let country: String?
        
        //@ThailandPostCode
        let postalCode: String?
        
        let phone: String?
        
        static func validations(_ validations: inout Validations) {
            //            if let postalCode {
            //                validations.add("postal_code", as: String.self,
            //                                is: .count(5...5))
            //            }
            //
            //            if let address {
            //                validations.add("address", as: String.self,
            //                                is: .count(1...200))
            //            }
            
            //     validations.add("address", as: String.self,
            //                     is: .count(1...200))
            //     validations.add("postalCode", as: String.self,
            //                     is: .count(5...5))
        }
        
        enum CodingKeys: String, CodingKey {
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone
        }
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
/*
 
 struct BusinessAddress: Content {
 
 let id: UUID
 let address: String
 let branch: String
 let subDistrict: String
 let city: String
 let province: String
 let country: String
 
 @ThailandPostCode
 var postalCode: String
 
 let phoneNumber: String
 let email: String
 let fax: String
 
 init(id: UUID = UUID(),
 address: String,
 branch: String,
 subDistrict: String,
 city: String,
 province: String,
 postalCode: String,
 country: String = "THA",
 phoneNumber: String = "",
 email: String = "",
 fax: String = "") {
 self.id = id
 self.address = address
 self.branch = branch
 self.subDistrict = subDistrict
 self.city = city
 self.province = province
 self.postalCode = postalCode
 self.country = country
 self.phoneNumber = phoneNumber
 self.email = email
 self.fax = fax
 }
 
 //decode
 init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 self.id = try container.decode(UUID.self,
 forKey: .id)
 self.address = (try? container.decode(String.self,
 forKey: .address)) ?? ""
 self.branch = (try? container.decode(String.self,
 forKey: .branch)) ?? ""
 self.subDistrict = (try? container.decode(String.self,
 forKey: .subDistrict)) ?? ""
 self.city = (try? container.decode(String.self,
 forKey: .city)) ?? ""
 self.province = (try? container.decode(String.self,
 forKey: .province)) ?? ""
 self.postalCode = (try? container.decode(String.self,
 forKey: .postalCode)) ?? ""
 self.country = (try? container.decode(String.self,
 forKey: .country)) ?? ""
 self.phoneNumber = (try? container.decode(String.self,
 forKey: .phoneNumber)) ?? ""
 self.email = (try? container.decode(String.self,
 forKey: .email)) ?? ""
 self.fax = (try? container.decode(String.self,
 forKey: .fax)) ?? ""
 
 }
 
 //encode
 func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode(id, forKey: .id)
 try container.encode(address, forKey: .address)
 try container.encode(branch, forKey: .branch)
 try container.encode(subDistrict, forKey: .subDistrict)
 try container.encode(city, forKey: .city)
 try container.encode(province, forKey: .province)
 try container.encode(postalCode, forKey: .postalCode)
 try container.encode(country, forKey: .country)
 try container.encode(phoneNumber, forKey: .phoneNumber)
 try container.encode(email, forKey: .email)
 try container.encode(fax, forKey: .fax)
 }
 
 enum CodingKeys: String, CodingKey {
 case id
 case address
 case branch
 case subDistrict = "sub_district"
 case city
 case province
 case postalCode = "postal_code"
 case country
 case phoneNumber = "phone_number"
 case email
 case fax
 }
 }*/

/*
 struct ShippingAddress: Codable {
 let id: UUID
 let address: String
 let branch: String
 let subDistrict: String
 let city: String
 let province: String
 let country: String
 
 @ThailandPostCode
 var postalCode: String
 
 let phoneNumber: String
 let email: String
 let fax: String
 
 init(id: UUID = .init(),
 address: String,
 branch: String,
 subDistrict: String,
 city: String,
 province: String,
 country: String = "THA",
 postalCode: String,
 phoneNumber: String = "",
 email: String = "",
 fax: String = "") {
 self.id = id
 self.address = address
 self.branch = branch
 self.subDistrict = subDistrict
 self.city = city
 self.province = province
 self.country = country
 self.postalCode = postalCode
 self.phoneNumber = phoneNumber
 self.email = email
 self.fax = fax
 }
 
 //decode
 init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 self.id = try container.decode(UUID.self, forKey: .id)
 self.address = (try? container.decode(String.self,
 forKey: .address)) ?? ""
 self.branch = (try? container.decode(String.self,
 forKey: .branch)) ?? ""
 self.subDistrict = (try? container.decode(String.self,
 forKey: .subDistrict)) ?? ""
 self.city = (try? container.decode(String.self,
 forKey: .city)) ?? ""
 self.province = (try? container.decode(String.self,
 forKey: .province)) ?? ""
 self.postalCode = (try? container.decode(String.self,
 forKey: .postalCode)) ?? ""
 self.country = (try? container.decode(String.self,
 forKey: .country)) ?? ""
 self.phoneNumber = (try? container.decode(String.self,
 forKey: .phoneNumber)) ?? ""
 self.email = (try? container.decode(String.self,
 forKey: .email)) ?? ""
 self.fax = (try? container.decode(String.self,
 forKey: .fax)) ?? ""
 }
 
 //encode
 func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode(id, forKey: .id)
 try container.encode(address, forKey: .address)
 try container.encode(branch, forKey: .branch)
 try container.encode(subDistrict, forKey: .subDistrict)
 try container.encode(city, forKey: .city)
 try container.encode(province, forKey: .province)
 try container.encode(postalCode, forKey: .postalCode)
 try container.encode(country, forKey: .country)
 try container.encode(phoneNumber, forKey: .phoneNumber)
 try container.encode(email, forKey: .email)
 try container.encode(fax, forKey: .fax)
 }
 
 enum CodingKeys: String, CodingKey {
 case id
 case address
 case branch
 case subDistrict = "sub_district"
 case city
 case province
 case postalCode = "postal_code"
 case country
 case phoneNumber = "phone_number"
 case email
 case fax
 }
 }
 
 */
