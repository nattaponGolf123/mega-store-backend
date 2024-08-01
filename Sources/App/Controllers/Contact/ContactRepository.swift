import Foundation
import Vapor
import Fluent
import FluentMongoDriver
import Mockable

@Mockable
protocol ContactRepositoryProtocol {
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    func fetchAll(request: FetchAll,
                  on db: Database) async throws -> PaginatedResponse<Contact>
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
    
    func create(request: ContactRequest.Create, on db: Database) async throws -> Contact
    func update(
        byId: GeneralRequest.FetchById,
        request: ContactRequest.Update,
        on db: Database
    ) async throws -> Contact
        
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> Contact
    func updateBussineseAddress(byId: GeneralRequest.FetchById,
                                addressID: GeneralRequest.FetchById,
                                request: ContactRequest.UpdateBussineseAddress, 
                                on db: Database) async throws -> Contact
    func updateShippingAddress(byId: GeneralRequest.FetchById,
                               addressID: GeneralRequest.FetchById,
                               request: ContactRequest.UpdateShippingAddress,
                               on db: Database) async throws -> Contact
    func search(request: Search,
                on db: Database) async throws -> PaginatedResponse<Contact>
    func fetchLastedNumber(on db: Database) async throws -> Int
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
