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
import MockableTest

@testable import App

final class ContactRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    private(set) var contactRepository: ContactRepository!
    lazy var contactGroupRepository = MockContactGroupRepositoryProtocol()
    
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
        
        contactRepository = ContactRepository(contactGroupRepository: contactGroupRepository)
        
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
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2", deletedAt: Date())
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
    
    func testFetchAll_WithShowDeleted_ShouldDeletedContact() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2", deletedAt: Date())
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(showDeleted: true),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    //perPage min at 20
    func testFetchAll_WithPagination_ShouldReturnContact() async throws {
        
        // Given
        let contacts = Stub.group40
        await createGroups(groups: contacts,
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
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2")
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact2")
    }
    
    func testFetchAll_WithSortByNameAsc_ShouldReturnContact() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2")
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact1")
    }
    
    func testFetchAll_WithSortByCreateAtDesc_ShouldReturnContact() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2")
        try await contact1.create(on: db)
        sleep(1)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .desc),
                                                               on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Contact2")
    }
    
    func testFetchAll_WithSortByCreateAtAsc_ShouldReturnContact() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2")
        try await contact1.create(on: db)
        sleep(1)
        try await contact2.create(on: db)
        
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
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        // When
        let result = try await contactRepository.fetchById(request: .init(id: contact.id!),
                                                                on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Contact")
    }
    
    //MARK: fetchByName
    func testFindFirstByName_ShouldReturnContact() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
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
        let contact = Contact(name: "Contact", taxNumber: "123456789")
        try await contact.create(on: db)
        
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
    
    //MARK: create
    func testCreate_ShouldCreateContact() async throws {
        
        // Given
        let group1 = ContactGroup(name: "Group 1")
        given(contactGroupRepository).fetchById(request: .any,
                                                on: .any).willReturn(group1)
        
        let request = ContactRequest.Create(name: "Contact",
                                            vatRegistered: false,
                                            legalStatus: .individual,
                                            groupId: group1.id)
        
        // When
        let result = try await contactRepository.create(request: request,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.number, 1)
        XCTAssertEqual(result.name, "Contact")
        XCTAssertEqual(result.groupId, group1.id)
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
        let contact = Contact(name: "Contact",
                            vatRegistered: false,
                            legalStatus: .individual)
        try await contact.create(on: db)
        
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
    
    func testCreate_WithDuplicateTaxNumber_ShouldThrowError() async throws {
        
        // Given
        let contact = Contact(name: "Contact",
                            vatRegistered: false,
                            taxNumber: "123456789",
                            legalStatus: .individual)
        try await contact.create(on: db)
        
        let request = ContactRequest.Create(name: "Contact 2",
                                            vatRegistered: false,
                                            taxNumber: "123456789",
                                            legalStatus: .individual)
        
        // When
        do {
            _ = try await contactRepository.create(request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateTaxNumber)
        }
    }
    
    func testCreate_WithNotExistGroupID_ShouldThrowError() async throws {
        
        // Given
        given(contactGroupRepository).fetchById(request: .any,
                                                on: .any).willThrow(DefaultError.notFound)
        
        let request = ContactRequest.Create(name: "Contact",
                                            vatRegistered: false,
                                            legalStatus: .individual,
                                            groupId: UUID())
        
        // When
        do {
            _ = try await contactRepository.create(request: request,
                                                        on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
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
                                             contactInformation: .init(contactPerson: "Contact Person",
                                                                       phone: "1234567890",
                                                                       email: "abc@email.com"),
                                             taxNumber: "123456788",
                                             legalStatus: .individual,
                                             website: "Website",
                                             note: "Note",
                                             paymentTermsDays: 28)
        
        let fetchById = GeneralRequest.FetchById(id: group.id!)
        
        // When
        let result = try await contactRepository.update(byId: fetchById,
                                                        request: request,
                                                        on: db)
        // Then
        XCTAssertEqual(result.name, "Contact2")
    }
    
    func testUpdate_WithExistGroupId_ShouldUpdateContact() async throws {
        
        // Given
        let group = ContactGroup(name: "Group 2")
        given(contactGroupRepository).fetchById(request: .any,
                                                on: .any).willReturn(group)
        
        let contact = Contact(name: "Contact",
                            groupId: nil)
        try await contact.create(on: db)
        
        let request = ContactRequest.Update(name: "Contact 3",
                                            vatRegistered: false,
                                            groupId: group.id)
        
        let fetchById = GeneralRequest.FetchById(id: contact.id!)
        
        // When
        let result = try await contactRepository.update(byId: fetchById,
                                                        request: request,
                                                        on: db)
        
        // Then
        XCTAssertEqual(result.groupId, group.id)
    }
    
    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1")
        let contact2 = Contact(name: "Contact2")
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        let request = ContactRequest.Update(name: "Contact2")
        
        let fetchById = GeneralRequest.FetchById(id: contact1.id!)
        
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
    
    func testUpdate_WithDuplicateTaxNumber_ShouldThrowError() async throws {
        
        // Given
        let contact1 = Contact(name: "Contact1",
                             vatRegistered: false,
                             taxNumber: "123456789")
        let contact2 = Contact(name: "Contact2",
                             vatRegistered: false,
                             taxNumber: "123456788")
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        
        let request = ContactRequest.Update(name: "Contact3",
                                            vatRegistered: false,
                                            taxNumber: "123456788")
        
        let fetchById = GeneralRequest.FetchById(id: contact1.id!)
        
        // When
        do {
            _ = try await contactRepository.update(byId: fetchById,
                                                   request: request,
                                                   on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateTaxNumber)
        }
    }
    
    func testUpdate_WithNotExistGroupId_ShouldThrowError() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        given(contactGroupRepository).fetchById(request: .any,
                                                on: .any).willThrow(DefaultError.notFound)
        
        let request = ContactRequest.Update(name: "Contact2",
                                            vatRegistered: false,
                                            legalStatus: .individual,
                                            groupId: UUID())
        
        let fetchById = GeneralRequest.FetchById(id: contact.id!)
        
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
    
    //MARK: updateBussineseAddress

    func testUpdateBusinessAddress_WithExistAddressAndValidInfo_ShouldUpdateContact() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let address = contact.businessAddress.first!
                
        let requestId = GeneralRequest.FetchById(id: contact.id!)
        let requestAddressId = GeneralRequest.FetchById(id: address.id)
        let request = ContactRequest.UpdateBussineseAddress(address: "928/12",
                                                            branch: "Head Office",
                                                            branchCode: "00000",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839",
                                                            email: "abc@email.com",
                                                            fax: "0293848839")        
        
        // When
        let result = try await contactRepository.updateBussineseAddress(byId: requestId,
                                                                        addressID: requestAddressId,
                                                                        request: request,
                                                                        on: db)
        
        // Then
        XCTAssertEqual(result.businessAddress.count, 1)
        XCTAssertEqual(result.businessAddress.first?.address, "928/12")
        XCTAssertEqual(result.businessAddress.first?.branch, "Head Office")
        XCTAssertEqual(result.businessAddress.first?.branchCode, "00000")
        XCTAssertEqual(result.businessAddress.first?.subDistrict, "Bank Chak")
        XCTAssertEqual(result.businessAddress.first?.district, "Prakanong")
        XCTAssertEqual(result.businessAddress.first?.province, "Bangkok")
        XCTAssertEqual(result.businessAddress.first?.country, "Thailand")
        XCTAssertEqual(result.businessAddress.first?.postalCode, "12345")
        XCTAssertEqual(result.businessAddress.first?.phone, "0293848839")
        XCTAssertEqual(result.businessAddress.first?.email, "abc@email.com")
        XCTAssertEqual(result.businessAddress.first?.fax, "0293848839")
        
    }
    
    func testUpdateBusinessAddress_WithNotContactId_ShouldThrowNotFound() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let address = contact.businessAddress.first!
        
        let requestId = GeneralRequest.FetchById(id: UUID())
        let requestAddressId = GeneralRequest.FetchById(id: address.id)
        let request = ContactRequest.UpdateBussineseAddress(address: "928/12",
                                                            branch: "Head Office",
                                                            branchCode: "00000",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839",
                                                            email: "",
                                                            fax: "")
        
        // When
        do {
            _ = try await contactRepository.updateBussineseAddress(byId: requestId,
                                                                   addressID: requestAddressId,
                                                                   request: request,
                                                                   on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    func testUpdateBusinessAddress_WithNotExistAddressId_ShouldThrowNotFound() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let requestId = GeneralRequest.FetchById(id: contact.id!)
        let requestAddressId = GeneralRequest.FetchById(id: UUID())
        let request = ContactRequest.UpdateBussineseAddress(address: "928/12",
                                                            branch: "Head Office",
                                                            branchCode: "00000",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839",
                                                            email: "", 
                                                            fax: "")
        
        // When
        do {
            _ = try await contactRepository.updateBussineseAddress(byId: requestId,
                                                                   addressID: requestAddressId,
                                                                   request: request,
                                                                   on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    //MARK: updateShippingAddress
    func testUpdateShippingAddress_ShouldUpdateShippingAddress() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let address = contact.shippingAddress.first!
        
        let requestId = GeneralRequest.FetchById(id: contact.id!)
        let requestAddressId = GeneralRequest.FetchById(id: address.id)
        let request = ContactRequest.UpdateShippingAddress(address: "928/12",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839")
        
        // When
        let result = try await contactRepository.updateShippingAddress(byId: requestId,
                                                                       addressID: requestAddressId,
                                                                       request: request,
                                                                       on: db)
        
        // Then
        XCTAssertEqual(result.shippingAddress.count, 1)
        XCTAssertEqual(result.shippingAddress.first?.address, "928/12")
        XCTAssertEqual(result.shippingAddress.first?.subDistrict, "Bank Chak")
        XCTAssertEqual(result.shippingAddress.first?.district, "Prakanong")
        XCTAssertEqual(result.shippingAddress.first?.province, "Bangkok")
        XCTAssertEqual(result.shippingAddress.first?.country, "Thailand")
        XCTAssertEqual(result.shippingAddress.first?.postalCode, "12345")
        XCTAssertEqual(result.shippingAddress.first?.phone, "0293848839")
    }
    
    func testUpdateShippingAddress_WithNotContactId_ShouldThrowNotFound() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let address = contact.shippingAddress.first!
        
        let requestId = GeneralRequest.FetchById(id: UUID())
        let requestAddressId = GeneralRequest.FetchById(id: address.id)
        let request = ContactRequest.UpdateShippingAddress(address: "928/12",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839")
        
        // When
        do {
            _ = try await contactRepository.updateShippingAddress(byId: requestId,
                                                                  addressID: requestAddressId,
                                                                  request: request,
                                                                  on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, .notFound)
        }
    }
    
    func testUpdateShippingAddress_WithNotExistAddressId_ShouldThrowNotFound() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let requestId = GeneralRequest.FetchById(id: contact.id!)
        let requestAddressId = GeneralRequest.FetchById(id: UUID())
        let request = ContactRequest.UpdateShippingAddress(address: "928/12",
                                                            subDistrict: "Bank Chak",
                                                            district: "Prakanong",
                                                            province: "Bangkok",
                                                            country: "Thailand",
                                                            postalCode: "12345",
                                                            phone: "0293848839")
        
        // When
        do {
            _ = try await contactRepository.updateShippingAddress(byId: requestId,
                                                                  addressID: requestAddressId,
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
        let contact = Contact(name: "Contact",
                            vatRegistered: false,
                            legalStatus: .individual)
        try await contact.create(on: db)
        
        let fetchById = GeneralRequest.FetchById(id: contact.id!)
        
        // When
        let result = try await contactRepository.delete(byId: fetchById,
                                                            on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
    
    //MARK: search
    func testSearch_WithName_ShouldReturnContact() async throws {
        
        // Given
        let contact = Contact(name: "Contact")
        try await contact.create(on: db)
        
        let request = GeneralRequest.Search(query: "Contact")
        
        // When
        let result = try await contactRepository.search(request: request,
                                                        on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Contact")
    }
    
    func testSearch_WithNumber_ShouldReturnContact() async throws {
        
        // Given
        let contact = Contact(number: 123)
        try await contact.create(on: db)
        
        let request = GeneralRequest.Search(query: "123")
        
        // When
        let result = try await contactRepository.search(request: request,
                                                        on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.number, 123)
    }
    
    //MARK: test fetchLastedNumber
    func testFetchLastedNumber_ShouldReturnNumber() async throws {
        
        // Given
        let contact = Contact(number: 1, 
                              name: "Contact")
        try await contact.create(on: db)
        
        // When
        let result = try await contactRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 1)
    }
    
    func testFetchLastedNumber_WithDeleted_ShouldReturnNumber() async throws {
        
        // Given
        let contact1 = Contact(number: 1,
                               name: "Contact")
        let contact2 = Contact(number: 2,
                               name: "Contact 2",
                               deletedAt: .init())
        
        try await contact1.create(on: db)
        try await contact2.create(on: db)
        
        // When
        let result = try await contactRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 2)
    }
    
    func testFetchLastedNumber_WithEmptyContact_ShouldReturn1() async throws {
        
        // When
        let result = try await contactRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 0)
    }
}

private extension ContactRepositoryTests {
    struct Stub {
        static var group40: [Contact] {
            (0..<40).map { Contact(name: "Contact\($0)") }
        }
    }
}
