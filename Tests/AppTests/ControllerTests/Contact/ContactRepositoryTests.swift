//
//  ContactRepositoryTests.swift
//  
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver

@testable import App

final class ContactRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    var contactRepository: ContactRepository!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ContactMigration())
        
        db = app.db
        
        contactRepository = ContactRepository()
        
        try await dropCollection(db,
                                 schema: Contact.schema)
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    //MARK: fetchAll
    func testFetchAll_ShouldReturnAllContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2", deletedAt: Date())
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
    
    func testFetchAll_WithShowDeleted_ShouldDeletedContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2", deletedAt: Date())
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(showDeleted: true),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    //perPage min at 20
    func testFetchAll_WithPagination_ShouldReturnContact() async throws {
        
        // Given
        let groups = Stub.group40
        await createGroups(groups: groups,
                           db: db)
        // When
        let result = try await contactRepository.fetchAll(request: .init(page: 2,
                                                                              perPage: 25),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 15)
    }
    
    func testFetchAll_WithSortByNameDesc_ShouldReturnContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact2")
    }
    
    func testFetchAll_WithSortByNameAsc_ShouldReturnContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
    
    func testFetchAll_WithSortByCreateAtDesc_ShouldReturnContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
    
    func testFetchAll_WithSortByCreateAtAsc_ShouldReturnContact() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
 
    //MARK: fetchById
    func testFetchById_ShouldReturnContact() async throws {
        
        // Given
        let group = Contact(name: "Contact")
        try await group.create(on: db)
        
        // When
        let result = try await contactRepository.fetchById(request: .init(id: group.id!),
                                                                on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Contact")
    }
    
    //MARK: fetchByName
    func testFindFirstByName_ShouldReturnContact() async throws {
        
        // Given
        let group = Contact(name: "Contact")
        try await group.create(on: db)
        
        // When
        let result = try await contactRepository.fetchByName(request: .init(name: "Contact"),
                                                                  on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Contact")
    }
    
    func testFindFirstByName_ShouldThrowNotFound() async throws {
        
        // Given
        let group = Contact(name: "Contact")
        try await group.create(on: db)
        
        // When
        do {
            _ = try await contactRepository.fetchByName(request: .init(name: "Contact1"),
                                                                 on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
        }
    }
    
    
    //MARK: fetchByTaxNumber
    func testFetchByTaxNumber_ShouldReturnContact() async throws {
        
        // Given
        let group = Contact(name: "Contact", taxNumber: "123456789")
        try await group.create(on: db)
        
        // When
        let result = try await contactRepository.fetchByTaxNumber(request: .init(taxNumber: "123456789"),
                                                                       on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.taxNumber, "123456789")
    }
    
    func testFetchByTaxNumber_ShouldThrowNotFound() async throws {
        
        // Given
        let group = Contact(name: "Contact", taxNumber: "123456789")
        try await group.create(on: db)
        
        // When
        do {
            _ = try await contactRepository.fetchByTaxNumber(request: .init(taxNumber: "987654321"),
                                                               on: db)
            XCTFail()
        } catch {
            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
        }
    }
    
    /*
     final class Contact: Model, Content {
         static let schema = "Contacts"
         
         @ID(key: .id)
         var id: UUID?
         
         @Field(key: "number")
         var number: Int
         
         @Enum(key: "kind")
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
         var taxNumber: String?
         
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
              taxNumber: String? = nil,
              legalStatus: BusinessType = .individual,
              website: String? = nil,
              businessAddress: [BusinessAddress] = [.init()],
              shippingAddress: [ShippingAddress] = [.init()],
              paymentTermsDays: Int = 30,
              note: String? = nil,
              createAt: Date? = nil,
              updatedAt: Date? = nil,
              deletedAt: Date? = nil) {
             
             self.id = id ?? UUID()
             self.number = number
             self.groupId = groupId
             self.kind = kind
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
             self.createdAt = createAt ?? .init()
             self.updatedAt = updatedAt
             self.deletedAt = deletedAt
             
         }
         
     }
     */
    //MARK: create
    func testCreate_ShouldCreateContact() async throws {
        
        // Given
        let request = ContactRequest.Create(name: "Contact",
                                            vatRegistered: false, 
                                            legalStatus: .individual)
        
        // When
        let result = try await contactRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.number, 1)
        XCTAssertEqual(result.name, "Contact")
        XCTAssertNil(result.groupId)
        XCTAssertEqual(result.kind, .both)
        XCTAssertEqual(result.vatRegistered, false)
        XCTAssertNil(result.taxNumber)
        XCTAssertEqual(result.legalStatus, .individual)
        XCTAssertNil(result.website)
        XCTAssertEqual(result.businessAddress.count, 1)
        XCTAssertEqual(result.shippingAddress.count, 1)
        XCTAssertEqual(result.paymentTermsDays, 30)
        XCTAssertNil(result.note)
        XCTAssertNotNil(result.createdAt)
        XCTAssertNotNil(result.updatedAt)
        XCTAssertNil(result.deletedAt)
    }
    
    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group = Contact(name: "Contact",
                            vatRegistered: false,
                            legalStatus: .individual)
        try await group.create(on: db)
        
        let request = ContactRequest.Create(name: "Contact",
                                            vatRegistered: false,
                                            legalStatus: .individual)
        
        // When
        do {
            _ = try await contactRepository.create(request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testCreate_WithVatRegistered_ShouldCreateContact() async throws {
        
        // Given
        let request = ContactRequest.Create(name: "Contact",
                                            vatRegistered: true,
                                            legalStatus: .individual)
        
        // When
        let result = try await contactRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.number, 1)
        XCTAssertEqual(result.name, "Contact")
        XCTAssertNil(result.groupId)
        XCTAssertEqual(result.kind, .both)
        XCTAssertEqual(result.vatRegistered, true)
        XCTAssertNil(result.taxNumber)
        XCTAssertEqual(result.legalStatus, .individual)
        XCTAssertNil(result.website)
        XCTAssertEqual(result.businessAddress.count, 1)
        XCTAssertEqual(result.shippingAddress.count, 1)
        XCTAssertEqual(result.paymentTermsDays, 30)
        XCTAssertNil(result.note)
        XCTAssertNotNil(result.createdAt)
        XCTAssertNotNil(result.updatedAt)
        XCTAssertNil(result.deletedAt)
    }
    
    //MARK: update
    
    func testUpdate_WithName_ShouldUpdateContact() async throws {
        
        // Given
        let group = Contact(name: "Contact")
        try await group.create(on: db)
        
        let request = ContactRequest.Update(name: "Contact2",
                                            vatRegistered: false,
                                            legalStatus: .individual)
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactRepository.update(byId: fetchById,
                                                        request: request,
                                                        on: db)
        // Then
        XCTAssertEqual(result.name, "Contact2")
    }
    
    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let group1 = Contact(name: "Contact1")
        let group2 = Contact(name: "Contact2")
        try await group1.create(on: db)
        try await group2.create(on: db)
        
        let request = ContactRequest.Update(name: "Contact2")
        
        let fetchById = GeneralRequest.FetchById(id: group1.id!)
        
        // When
        do {
            _ = try await contactRepository.update(byId: fetchById,
                                                   request: request,
                                                   on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testUpdate_WithNotFoundId_ShouldThrowError() async throws {
        
        // Given
        let request = ContactRequest.Update(name: "Contact2")
        
        let fetchById = GeneralRequest.FetchById(id: UUID())
        
        // When
        do {
            _ = try await contactRepository.update(byId: fetchById,
                                                   request: request,
                                                   on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: delete
    func testDelete_ShouldDeleteContact() async throws {
        
        // Given
        let group = Contact(name: "Contact",
                            vatRegistered: false,
                            legalStatus: .individual)
        try await group.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactRepository.delete(byId: fetchById,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
}

private extension ContactRepositoryTests {
    struct Stub {
        static var group40: [Contact] {
            (0..<40).map { Contact(name: "Contact\($0)") }
        }
    }
}

/*
 //
 //  File.swift
 //
 //
 //  Created by IntrodexMac on 3/5/2567 BE.
 //

 import Foundation
 import Vapor
 import Fluent

 enum ContactKind: String, Codable {
     case customer = "CUSTOMER"
     case supplier = "SUPPLIER"
     case both = "BOTH"
 }

 final class Contact: Model, Content {
     static let schema = "Contacts"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "number")
     var number: Int
     
     @Enum(key: "kind")
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
     var taxNumber: String?
     
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
          taxNumber: String? = nil,
          legalStatus: BusinessType = .individual,
          website: String? = nil,
          businessAddress: [BusinessAddress] = [.init()],
          shippingAddress: [ShippingAddress] = [.init()],
          paymentTermsDays: Int = 30,
          note: String? = nil,
          createAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil) {
         
         self.id = id ?? UUID()
         self.number = number
         self.groupId = groupId
         self.kind = kind
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
         self.createdAt = createAt ?? .init()
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
         
     }
     
 }

 extension Contact {
     struct Stub {
         static var customer: Contact {
             Contact(number: 1,
                     name: "ABC Company",
                     kind: .customer,
                     vatRegistered: true,
                     contactInformation: ContactInformation(contactPerson: "John Doe",
                                                            phone: "123-456-7890",
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
             Contact(number: 2,
                     name: "ABC Industries",
                     kind: .supplier,
                     vatRegistered: true,
                     contactInformation: ContactInformation(contactPerson: "John Doe",
                                                            phone: "123-456-7890",
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
             Contact(number: 1,
                     name: "ABC Industries",
                     kind: .both,
                     vatRegistered: true,
                     contactInformation: ContactInformation(contactPerson: "John Doe",
                                                            phone: "123-456-7890",
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

 /*
 final class ContactGroup: Model, Content {
     static let schema = "ContactGroups"
     
     @ID(key: .id)
     var id: UUID?

     @Field(key: "name")
     var name: String

     @Field(key: "description")
     var description: String?

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
          name: String,
          description: String?,
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil) {
         self.id = id ?? UUID()
         self.name = name
         self.description = description
         self.createdAt = createdAt
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
     }
     
 }
 */
 /*
  {
  "id": "SUP12345", // UUID
  "name": "ABC Industries",
  "vat_registered": true,
  "contact_information": {
  "contact_person": "John Doe",
  "phone_number": "123-456-7890",
  "email": "contact@abcindustries.com",
  "address": "1234 Industrial Way, Business City, BC 56789"
  },
  "tax_number": "123123212123",
  "legal_tatus" : "corporate" , // ["limited company", "individual"]
  "website": "www.abcindustries.com",
  "businese_address": [{
  "address" : "123",
  "city" : "Bangkok",
  "postal_code" : "12022",
  "country" : "Thailand",
  "phone_number" : "123-456-7890"
  "email" : "",
  "fax" : ""
  }],
  
  "payment_terms_days": 30,
  "note": "Reliable Contact with consistent quality and delivery times.",
  "created_at": "2021-03-05T07:00:00Z",
  "updated_at": "2021-03-05T07:00:00Z",
  "deleted_at": null
  }
  */

 /*
  @propertyWrapper
  struct ContactCode {
  private var value: String
  
  init(wrappedValue: String) {
  self.value = wrappedValue
  }
  
  init(wrappedValue: Int) {
  self.value = String(wrappedValue)
  }
  
  var wrappedValue: String {
  get { value }
  set {
  if isValidContactCode(newValue) {
  value = newValue
  } else {
  print("Invalid Contact code format")
  }
  }
  }
  
  private func isValidContactCode(_ code: String) -> Bool {
  let regex = #"^S\d{4}\d$"#
  let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
  return predicate.evaluate(with: code)
  }
  }
  */

 */
/*
 import Foundation
 import Vapor
 import Fluent
 import FluentMongoDriver
 import Mockable

 @Mockable
 protocol ContactRepositoryProtocol {
     typealias FetchAll = GeneralRequest.FetchAll
     typealias Search = GeneralRequest.Search
     
     func fetchAll(
         request: FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact
     
     func fetchByName(
         request: GeneralRequest.FetchByName,
         on db: Database
     ) async throws -> Contact
     
     func fetchByTaxNumber(
         request: GeneralRequest.FetchByTaxNumber,
         on db: Database
     ) async throws -> Contact
     
     func create(
         request: ContactRequest.Create,
         on db: Database
     ) async throws -> Contact
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ContactRequest.Update,
         on db: Database
     ) async throws -> Contact
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact
     
     func updateBussineseAddress(
         byId: GeneralRequest.FetchById,
         addressID: GeneralRequest.FetchById,
         request: ContactRequest.UpdateBussineseAddress,
         on db: Database
     ) async throws -> Contact
     
     func updateShippingAddress(
         byId: GeneralRequest.FetchById,
         addressID: GeneralRequest.FetchById,
         request: ContactRequest.UpdateShippingAddress,
         on db: Database
     ) async throws -> Contact
     
     func search(
         request: Search,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func fetchLastedNumber(
         on db: Database
     ) async throws -> Int
 }

 class ContactRepository: ContactRepositoryProtocol {
     
     typealias FetchAll = GeneralRequest.FetchAll
     typealias Search = GeneralRequest.Search
     
     private var contactGroupRepository: ContactGroupRepositoryProtocol
     
     init(contactGroupRepository: ContactGroupRepositoryProtocol = ContactGroupRepository()) {
         self.contactGroupRepository = contactGroupRepository
     }
     
     func fetchAll(request: FetchAll, on db: any Database) async throws -> PaginatedResponse<Contact> {
         
         let query = Contact.query(on: db)
         
         if request.showDeleted {
             query.withDeleted()
         } else {
             query.filter(\.$deletedAt == nil)
         }
         
         
         let total = try await query.count()
         let items = try await sortQuery(query: query,
                                         sortBy: request.sortBy,
                                         sortOrder: request.sortOrder,
                                         page: request.page,
                                         perPage: request.perPage)
         
         let response = PaginatedResponse(page: request.page,
                                          perPage: request.perPage,
                                          total: total,
                                          items: items)
         
         return response
     }
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact {
         guard
             let found = try await Contact.query(on: db).filter(\.$id == request.id).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func fetchByName(
         request: GeneralRequest.FetchByName,
         on db: Database
     ) async throws -> Contact {
         guard
             let found = try await Contact.query(on: db).filter(\.$name == request.name).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func fetchByTaxNumber(
         request: GeneralRequest.FetchByTaxNumber,
         on db: Database
     ) async throws -> Contact {
         guard
             let found = try await Contact.query(on: db).filter(\.$taxNumber == request.taxNumber).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func create(request: ContactRequest.Create, on db: Database) async throws -> Contact {
         // prevent duplicate name
         if let _ = try? await fetchByName(request: .init(name: request.name),
                                           on: db) {
             throw CommonError.duplicateName
         }
         
         // prevent duplicate tax number
         if let taxNumber = request.taxNumber,
            let _ = try? await fetchByTaxNumber(request: .init(taxNumber: taxNumber),
                                                on: db) {
             throw CommonError.duplicateName
         }
         
         if let groupId = request.groupId,
            let _ = try? await contactGroupRepository.fetchById(request: .init(id: groupId),
                                                                on: db) {
             throw DefaultError.notFound
         }
         
         let lastedNumber = try await fetchLastedNumber(on: db)
         let nextNumber = lastedNumber + 1
         
         let contact = Contact(number: nextNumber,
                               name: request.name,
                               groupId: request.groupId,
                               vatRegistered: request.vatRegistered,
                               contactInformation: request.contactInformation ?? .init(),
                               taxNumber: request.taxNumber,
                               legalStatus: request.legalStatus,
                               website: request.website,
                               businessAddress: [.init()],
                               shippingAddress: [.init()],
                               paymentTermsDays: request.paymentTermsDays ?? 30,
                               note: request.note)
         try await contact.save(on: db)
         return contact
     }
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ContactRequest.Update,
         on db: Database
     ) async throws -> Contact {
         let contact = try await fetchById(request: .init(id: byId.id), on: db)
         
         if let name = request.name {
             // prevent duplicate name
             if let _ = try? await fetchByName(request: .init(name: name),
                                               on: db) {
                 throw CommonError.duplicateName
             }
             
             contact.name = name
         }
         
         if let taxNumber = request.taxNumber {
             // prevent duplicate tax number
             if let _ = try? await fetchByTaxNumber(request: .init(taxNumber: taxNumber),
                                                    on: db) {
                 throw CommonError.duplicateTaxNumber
             }
             
             contact.taxNumber = taxNumber
         }
         
         if let groupId = request.groupId {
             // try to fetch group id to check is exist
             if let _ = try? await contactGroupRepository.fetchById(request: .init(id: groupId),
                                                                    on: db) {
                 contact.groupId = groupId
             }
             else {
                 throw DefaultError.notFound
                 
             }
         }
         
         if let vatRegistered = request.vatRegistered {
             contact.vatRegistered = vatRegistered
         }
         
         if let contactInformation = request.contactInformation {
             contact.contactInformation = contactInformation
         }
         
         if let legalStatus = request.legalStatus {
             contact.legalStatus = legalStatus
         }
         
         if let website = request.website {
             contact.website = website
         }
         
         if let note = request.note {
             contact.note = note
         }
         
         if let paymentTermsDays = request.paymentTermsDays {
             contact.paymentTermsDays = paymentTermsDays
         }
         
         try await contact.save(on: db)
         return contact
     }
     
     func updateBussineseAddress(byId: GeneralRequest.FetchById,
                                 addressID: GeneralRequest.FetchById,
                                 request: ContactRequest.UpdateBussineseAddress,
                                 on db: Database) async throws -> Contact {
         guard let contact = try await Contact.find(byId.id, on: db) else {
             throw DefaultError.notFound
         }
         
         guard var addr = contact.businessAddress.first(where: { $0.id == addressID.id }) else {
             throw DefaultError.notFound
         }
         
         if let address = request.address {
             addr.address = address
         }
         
         if let branch = request.branch {
             addr.branch = branch
         }
         
         if let branchCode = request.branchCode {
             addr.branchCode = branchCode
         }
         
         if let subDistrict = request.subDistrict {
             addr.subDistrict = subDistrict
         }
         
         if let city = request.city {
             addr.city = city
         }
         
         if let province = request.province {
             addr.province = province
         }
         
         if let postalCode = request.postalCode {
             addr.postalCode = postalCode
         }
         
         if let country = request.country {
             addr.country = country
         }
         
         if let phone = request.phone {
             addr.phone = phone
         }
         
         if let email = request.email {
             addr.email = email
         }
         
         if let fax = request.fax {
             addr.fax = fax
         }
         
         contact.businessAddress = [addr]
         
         try await contact.save(on: db)
         return contact
     }
     
     func updateShippingAddress(byId: GeneralRequest.FetchById,
                                addressID: GeneralRequest.FetchById,
                                request: ContactRequest.UpdateShippingAddress,
                                on db: Database) async throws -> Contact {
         guard let contact = try await Contact.find(byId.id, on: db) else {
             throw DefaultError.notFound
         }
         
         guard var addr = contact.shippingAddress.first(where: { $0.id == addressID.id }) else {
             throw DefaultError.notFound
         }
         
         if let address = request.address {
             addr.address = address
         }
         
         if let subDistrict = request.subDistrict {
             addr.subDistrict = subDistrict
         }
         
         if let city = request.city {
             addr.city = city
         }
         
         if let province = request.province {
             addr.province = province
         }
         
         if let postalCode = request.postalCode {
             addr.postalCode = postalCode
         }
         
         if let country = request.country {
             addr.country = country
         }
         
         if let phone = request.phone {
             addr.phone = phone
         }
         
         contact.shippingAddress = [addr]
         
         try await contact.save(on: db)
         return contact
     }
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact {
         let group = try await fetchById(request: .init(id: byId.id),
                                         on: db)
         try await group.delete(on: db)
         return group
     }
     
     func search(request: GeneralRequest.Search,
                 on db: Database) async throws -> PaginatedResponse<Contact> {
         
         let q = request.query
         let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
         let query = Contact.query(on: db).group(.or) { or in
             or.filter(\.$name =~ regexPattern)
             if let number = Int(q) {
                 or.filter(\.$number == number)
             }
             or.filter(\.$taxNumber =~ regexPattern)
             or.filter(\.$website =~ regexPattern)
             or.filter(\.$note =~ regexPattern)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(query: query,
                                         sortBy: request.sortBy,
                                         sortOrder: request.sortOrder,
                                         page: request.page,
                                         perPage: request.perPage)
         
         
         let response = PaginatedResponse(page: request.page,
                                          perPage: request.perPage,
                                          total: total,
                                          items: items)
         return response
     }
     
     func fetchLastedNumber(on db: Database) async throws -> Int {
         let query = Contact.query(on: db).withDeleted()
         query.sort(\.$number, .descending)
         query.limit(1)
         
         let model = try await query.first()
         
         return model?.number ?? 0
     }
     
 }
 private extension ContactRepository {
     func sortQuery(query: QueryBuilder<Contact>,
                    sortBy: SortBy,
                    sortOrder: SortOrder,
                    page: Int,
                    perPage: Int) async throws -> [Contact] {
         let pageIndex = (page - 1)
         let pageStart = pageIndex * perPage
         let pageEnd = pageStart + perPage
         
         let range = pageStart..<pageEnd
         
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range(range).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range(range).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range(range).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range(range).all()
             }
         case .groupId:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$groupId).range(range).all()
             case .desc:
                 return try await query.sort(\.$groupId, .descending).range(range).all()
             }
         case .number:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$number).range(range).all()
             case .desc:
                 return try await query.sort(\.$number, .descending).range(range).all()
             }
         default:
             return try await query.range(range).all()
         }
         
     }
 }

 */

/*
 @Mockable
 protocol ContactRepositoryProtocol {

     func fetchAll(
         request: ContactRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact?
     
     func fetchByName(
         request: ContactRequest.FetchByName,
         on db: Database
     ) async throws -> Contact?
     
     func searchByName(
         request: ContactRequest.Search,
         on db: Database
     ) async throws -> PaginatedResponse<Contact>
     
     func create(
         request: ContactRequest.Create,
         on db: Database
     ) async throws -> Contact
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ContactRequest.Update,
         on db: Database
     ) async throws -> Contact
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact
 }

 class ContactRepository: ContactRepositoryProtocol {
         
     func fetchAll(
         request: ContactRequest.FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<Contact> {
         let query = Contact.query(on: db)
         
         if request.showDeleted {
             query.withDeleted()
         } else {
             query.filter(\.$deletedAt == nil)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(
             query: query,
             sortBy: request.sortBy,
             sortOrder: request.sortOrder,
             page: request.page,
             perPage: request.perPage
         )
         
         let response = PaginatedResponse(
             page: request.page,
             perPage: request.perPage,
             total: total,
             items: items
         )
         
         return response
     }
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact? {
         return try await Contact.query(on: db).filter(\.$id == request.id).first()
     }
     
     func fetchByName(
         request: ContactRequest.FetchByName,
         on db: Database
     ) async throws -> Contact? {
         return try await Contact.query(on: db).filter(\.$name == request.name).first()
     }
     
     func searchByName(
         request: ContactRequest.Search,
         on db: Database
     ) async throws -> PaginatedResponse<Contact> {
         let regexPattern = "(?i)\(request.query)"
         let query = Contact.query(on: db).filter(\.$name =~ regexPattern)
         
         let total = try await query.count()
         let items = try await sortQuery(
             query: query,
             sortBy: request.sortBy,
             sortOrder: request.sortOrder,
             page: request.page,
             perPage: request.perPage
         )
         
         let response = PaginatedResponse(
             page: request.page,
             perPage: request.perPage,
             total: total,
             items: items
         )
         
         return response
     }
     
     func create(
         request: ContactRequest.Create,
         on db: Database
     ) async throws -> Contact {
         // prevent duplicate name
         if let _ = try await fetchByName(request: .init(name: request.name),
                                          on: db) {
             throw CommonError.duplicateName
         }
         
         let group = Contact(name: request.name,
                                  description: request.description)
         try await group.save(on: db)
         return group
     }
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ContactRequest.Update,
         on db: Database
     ) async throws -> Contact {
         guard
             var group = try await fetchById(request: .init(id: byId.id),
                                            on: db)
         else { throw Abort(.notFound) }
       
         if let name = request.name {
             // prevent duplicate name
             if let _ = try await fetchByName(request: .init(name: name),
                                              on: db) {
                 throw CommonError.duplicateName
             }
             
             group.name = name
         }
         
         if let description = request.description {
             group.description = description
         }
         
         try await group.save(on: db)
         return group
     }
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Contact {
         guard
             var group = try await fetchById(request: .init(id: byId.id),
                                            on: db)
         else { throw Abort(.notFound) }
         
         try await group.delete(on: db)
         return group
     }
     
 }

 private extension ContactRepository {
     func sortQuery(
         query: QueryBuilder<Contact>,
         sortBy: ContactRequest.SortBy,
         sortOrder: ContactRequest.SortOrder,
         page: Int,
         perPage: Int
     ) async throws -> [Contact] {
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         }
     }
 }

 */

/*
 final class ContactGroupRepositoryTests: XCTestCase {
     
     var app: Application!
     var db: Database!
     var contactRepository: ContactGroupRepository!
     
     // Database configuration
     var dbHost: String!
     
     override func setUp() async throws {
         try await super.setUp()
         
         app = Application(.testing)
         dbHost = try dbHostURL(app)
         
         try configure(app,
                       dbHost: dbHost,
                       migration: ContactGroupMigration())
         
         db = app.db
         
         contactRepository = ContactGroupRepository()
         
         try await dropCollection(db,
                                  schema: ContactGroup.schema)
     }

     override func tearDown() async throws {
         
         app.shutdown()
         try await super.tearDown()
     }
     
     //MARK: fetchAll
     func testFetchAll_ShouldReturnAllGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2", deletedAt: Date())
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.fetchAll(request: .init(),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 1)
         XCTAssertEqual(result.items.first?.name, "Group1")
     }
     
     func testFetchAll_WithShowDeleted_ShouldDeletedGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2", deletedAt: Date())
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.fetchAll(request: .init(showDeleted: true),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
     }
     
     //perPage min at 20
     func testFetchAll_WithPagination_ShouldReturnGroup() async throws {
         
         // Given
         let groups = Stub.group40
         await createGroups(groups: groups,
                            db: db)
         // When
         let result = try await contactRepository.fetchAll(request: .init(page: 2,
                                                                               perPage: 25),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 15)
     }
     
     func testFetchAll_WithSortByNameDesc_ShouldReturnGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         
         let result = try await contactRepository.fetchAll(request: .init(sortBy: .name,
                                                                               sortOrder: .desc),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
         XCTAssertEqual(result.items.first?.name, "Group2")
     }
     
     func testFetchAll_WithSortByNameAsc_ShouldReturnGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
         XCTAssertEqual(result.items.first?.name, "Group1")
     }
     
     func testFetchAll_WithSortByCreateAtDesc_ShouldReturnGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .desc),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
         XCTAssertEqual(result.items.first?.name, "Group1")
     }
     
     func testFetchAll_WithSortByCreateAtAsc_ShouldReturnGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc),
                                                                on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
         XCTAssertEqual(result.items.first?.name, "Group1")
     }
     
     //MARK: fetchById
     func testFetchById_ShouldReturnGroup() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         // When
         let result = try await contactRepository.fetchById(request: .init(id: group.id!),
                                                                 on: db)
         
         // Then
         XCTAssertNotNil(result)
         XCTAssertEqual(result.name, "Group")
     }
     
     //MARK: fetchByName
     func testFindFirstByName_ShouldReturnGroup() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         // When
         let result = try await contactRepository.fetchByName(request: .init(name: "Group"),
                                                                   on: db)
         
         // Then
         XCTAssertNotNil(result)
         XCTAssertEqual(result.name, "Group")
     }
     
     //MARK: searchByName
     func testSearchByName_WithExistChar_ShouldReturnGroups() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.searchByName(request: .init(query: "Gr"),
                                                                    on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 2)
     }
     
     func testSearchByName_WithNotExistChar_ShouldNotFoundAnyGroup() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         // When
         let result = try await contactRepository.searchByName(request: .init(query: "X"),
                                                                    on: db)
         
         // Then
         XCTAssertEqual(result.items.count, 0)
     }
     
     //MARK: create
     func testCreate_ShouldCreateGroup() async throws {
         
         // Given
         let request = ContactGroupRequest.Create(name: "Group")
         
         // When
         let result = try await contactRepository.create(request: request,
                                                             on: db)
         
         // Then
         XCTAssertEqual(result.name, "Group")
     }
     
     func testCreate_WithDuplicateName_ShouldThrowError() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         let request = ContactGroupRequest.Create(name: "Group")
         
         // When
         do {
             _ = try await contactRepository.create(request: request,
                                                         on: db)
             XCTFail("Should throw error")
         } catch {
             // Then
             XCTAssertEqual(error as? CommonError, .duplicateName)
         }
     }
     
     func testCreate_WithNameAndDescription_ShouldCreateGroup() async throws {
         
         // Given
         let request = ContactGroupRequest.Create(name: "Group",
                                                  description: "Des")
         
         // When
         let result = try await contactRepository.create(request: request,
                                                             on: db)
         
         // Then
         XCTAssertEqual(result.name, "Group")
         XCTAssertEqual(result.description ?? "", "Des")
     }
     
     //MARK: update
     func testUpdate_WithNameAndDescription_ShouldUpdateGroup() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         let request = ContactGroupRequest.Update(name: "Group2",
                                                  description: "Des")
         
         let fetchById = GeneralRequest.FetchById(id: group.id!)
         
         // When
         let result = try await contactRepository.update(byId: fetchById,
                                                              request: request,
                                                              on: db)
         // Then
         XCTAssertEqual(result.name, "Group2")
     }
     
     func testUpdate_WithDescription_ShouldUpdateGroup() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         let request = ContactGroupRequest.Update(name: nil,
                                                  description: "Des")
         
         let fetchById = GeneralRequest.FetchById(id: group.id!)
         
         // When
         let result = try await contactRepository.update(byId: fetchById,
                                                              request: request,
                                                              on: db)
         // Then
         XCTAssertEqual(result.description ?? "", "Des")
     }
     
     func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
         
         // Given
         let group1 = ContactGroup(name: "Group1")
         let group2 = ContactGroup(name: "Group2")
         try await group1.create(on: db)
         try await group2.create(on: db)
         
         let request = ContactGroupRequest.Update(name: "Group2",
                                                  description: "Des")
         
         let fetchById = GeneralRequest.FetchById(id: group1.id!)
         
         // When
         do {
             _ = try await contactRepository.update(byId: fetchById,
                                                         request: request,
                                                         on: db)
             XCTFail("Should throw error")
         } catch {
             // Then
             XCTAssertEqual(error as? CommonError, .duplicateName)
         }
     }
     
     func testUpdate_WithNotFoundId_ShouldThrowError() async throws {
         
         // Given
         let request = ContactGroupRequest.Update(name: "Group2",
                                                  description: "Des")
         
         let fetchById = GeneralRequest.FetchById(id: UUID())
         
         // When
         do {
             _ = try await contactRepository.update(byId: fetchById,
                                                         request: request,
                                                         on: db)
             XCTFail("Should throw error")
         } catch {
             // Then
             XCTAssertEqual(error as? DefaultError, .notFound)
         }
     }
     
     //MARK: delete
     func testDelete_ShouldDeleteGroup() async throws {
         
         // Given
         let group = ContactGroup(name: "Group")
         try await group.create(on: db)
         
         let fetchById = GeneralRequest.FetchById(id: group.id!)
         
         // When
         let result = try await contactRepository.delete(byId: fetchById,
                                                             on: db)
         
         // Then
         XCTAssertNotNil(result.deletedAt)
     }
 }

 private extension ContactGroupRepositoryTests {
     struct Stub {
         static var group40: [ContactGroup] {
             (0..<40).map { ContactGroup(name: "Group\($0)") }
         }
     }
 }

 */
