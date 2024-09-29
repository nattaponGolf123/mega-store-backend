import Foundation
import Vapor
import Fluent
import Mockable

@Mockable
protocol ServiceRepositoryProtocol {
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    func fetchAll(
        request: FetchAll,
        on db: Database
    ) async throws -> PaginatedResponse<App.Service>
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> App.Service
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> App.Service
    
    func create(
        request: ServiceRequest.Create,
        on db: Database
    ) async throws -> App.Service
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceRequest.Update,
        on db: Database
    ) async throws -> App.Service
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> App.Service
    
    func search(
        request: Search,
        on db: Database
    ) async throws -> PaginatedResponse<App.Service>
    
    func fetchLastedNumber(
        on db: Database
    ) async throws -> Int
}


class ServiceRepository: ServiceRepositoryProtocol {
    
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    typealias Service = App.Service
    
    private var serviceCategoryRepository: ServiceCategoryRepositoryProtocol
    
    init(serviceCategoryRepository: ServiceCategoryRepositoryProtocol = ServiceCategoryRepository()) {
        self.serviceCategoryRepository = serviceCategoryRepository
    }
    
    func fetchAll(
        request: FetchAll,
        on db: any Database
    ) async throws -> PaginatedResponse<App.Service> {
        
        let query = Service.query(on: db)
            .with(\.$category)
        
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
    ) async throws -> App.Service {
        let query = Service.query(on: db)
            .with(\.$category)
            .filter(\.$id == request.id)
        
        guard
            let found = try await query.first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> App.Service {
        let query = Service.query(on: db)
            .with(\.$category)
            .filter(\.$name == request.name)
        
        guard
            let found = try await query.first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func create(
        request: ServiceRequest.Create,
        on db: Database
    ) async throws -> App.Service {
        // prevent duplicate name
        if let _ = try? await fetchByName(request: .init(name: request.name),
                                          on: db) {
            throw CommonError.duplicateName
        }
        
        if let groupId = request.categoryId {
            guard
                let _ = try? await serviceCategoryRepository.fetchById(request: .init(id: groupId),
                                                                                 on: db)
            else { throw DefaultError.notFound }
        }
        
        let lastedNumber = try await fetchLastedNumber(on: db)
        let nextNumber = lastedNumber + 1
        
        let service = Service(number: nextNumber,
                              name: request.name,
                              description: request.description,
                              price: request.price,
                              unit: request.unit,
                              categoryId: request.categoryId,
                              images: request.images,
                              coverImage: request.coverImage,
                              tags: request.tags)
        
        try await service.create(on: db)
        return try await fetchById(request: .init(id: service.id!),
                                   on: db)
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceRequest.Update,
        on db: Database
    ) async throws -> App.Service {
        let service = try await fetchById(request: .init(id: byId.id), on: db)
        
        if let name = request.name {
            // prevent duplicate name
            if let _ = try? await fetchByName(request: .init(name: name),
                                              on: db) {
                throw CommonError.duplicateName
            }
            
            service.name = name
        }
        
        if let categoryId = request.categoryId {
            // try to fetch category id to check is exist
            guard
                let _ = try? await serviceCategoryRepository.fetchById(request: .init(id: categoryId),
                                                                   on: db)
            else { throw DefaultError.notFound }
            
            service.$category.id = categoryId
        }
        
        if let description = request.description {
            service.description = description
        }
        
        if let price = request.price {
            service.price = price
        }
        
        if let unit = request.unit {
            service.unit = unit
        }
        
        if let images = request.images {
            service.images = images
        }
        
        if let coverImage = request.coverImage {
            service.coverImage = coverImage
        }
        
        if let tags = request.tags {
            service.tags = tags
        }
        
        try await service.save(on: db)
        
        return service
    }
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> App.Service {
        let service = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        try await service.delete(on: db)
        
        return service
    }
    
    func search(request: Search,
                on db: Database) async throws -> PaginatedResponse<App.Service> {
        
        let q = request.query
        let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
        let query = Service.query(on: db)
            .with(\.$category)
            .group(.or) { or in
            or.filter(\.$name =~ regexPattern)
            if let number = Int(q) {
                or.filter(\.$number == number)
            }
            or.filter(\.$description =~ regexPattern)
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
    
    func fetchLastedNumber(
        on db: Database
    ) async throws -> Int {
        let query = Service.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)
        
        let model = try await query.first()
        
        return model?.number ?? 0
    }
    
}

//    enum SortBy: String, Codable {
//        case name
//        case number
//        case price
//        case categoryId = "category_id"
//        case createdAt = "created_at"
//    }
//
private extension ServiceRepository {
    func sortQuery(query: QueryBuilder<App.Service>,
                   sortBy: SortBy,
                   sortOrder: SortOrder,
                   page: Int,
                   perPage: Int) async throws -> [App.Service] {
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
        case .groupName:
            switch sortOrder {
            case .asc:
                return try await query.sort(ServiceCategory.self, \.$name).range(range).all()
            case .desc:
                return try await query.sort(ServiceCategory.self, \.$name, .descending).range(range).all()
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
