import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ServiceRepositoryProtocol {
//    func fetchAll(req: GeneralRequest.FetchAll,
//                  on db: Database) async throws -> PaginatedResponse<ServiceResponse>
//    func create(content: ServiceRequest.Create, on db: Database) async throws -> ServiceResponse
//    func find(id: UUID, on db: Database) async throws -> ServiceResponse
//    func find(name: String, on db: Database) async throws -> ServiceResponse
//    func update(id: UUID, with content: ServiceRequest.Update, on db: Database) async throws -> ServiceResponse
//    func delete(id: UUID, on db: Database) async throws -> ServiceResponse
//    func search(req: GeneralRequest.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse>
//    func fetchLastedNumber(on db: Database) async throws -> Int
//    
    // new
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    func fetchAll(
        request: FetchAll,
        on db: Database
    ) async throws -> PaginatedResponse<Service>
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> Service
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> Service
    
    func create(
        request: ServiceRequest.Create,
        on db: Database
    ) async throws -> Service
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceRequest.Update,
        on db: Database
    ) async throws -> Service
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> Service
    
    func search(
        request: Search,
        on db: Database
    ) async throws -> PaginatedResponse<Service>
    
    func fetchLastedNumber(
        on db: Database
    ) async throws -> Int
}


class ServiceRepository: ServiceRepositoryProtocol {
    
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    private var serviceCategoryRepository: ServiceCategoryRepositoryProtocol
    
    init(serviceCategoryRepository: ServiceCategoryRepositoryProtocol = ServiceCategoryRepository()) {
        self.serviceCategoryRepository = serviceCategoryRepository
    }
    
    func fetchAll(
        request: FetchAll,
        on db: any Database
    ) async throws -> PaginatedResponse<Service> {
        
        let query = Service.query(on: db)
        
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
    ) async throws -> Service {
        guard
            let found = try await Service.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> Service {
        guard
            let found = try await Service.query(on: db).filter(\.$name == request.name).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func create(
        request: ServiceRequest.Create,
        on db: Database
    ) async throws -> Service {
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
        
        try await service.save(on: db)
        return service
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceRequest.Update,
        on db: Database
    ) async throws -> Service {
        var service = try await fetchById(request: .init(id: byId.id), on: db)
        
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
            
            service.categoryId = categoryId
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
    ) async throws -> Service {
        let group = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        try await group.delete(on: db)
        return group
    }
    
    func search(
        request: GeneralRequest.Search,
                on db: Database
    ) async throws -> PaginatedResponse<Service> {
        
        let q = request.query
        let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
        let query = Service.query(on: db).group(.or) { or in
            or.filter(\.$name =~ regexPattern)
            if let number = Int(q) {
                or.filter(\.$number == number)
            }
            or.filter(\.$description =~ regexPattern)
            
            //contain on tags string
            //or.filter(\.$tags, .custom("ILIKE"), regexPattern)
        }
        
        let total = try await query.count()
        let items = try await sortQuery(query: query,
                                        sortBy: request.sortBy,
                                        sortOrder: request.sortOrder,
                                        page: request.page,
                                        perPage: request.perPage)
        let responseItems = items.map { $0 }
        
        let response = PaginatedResponse(page: request.page,
                                         perPage: request.perPage,
                                         total: total,
                                         items: responseItems)
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
    func sortQuery(query: QueryBuilder<Service>,
                   sortBy: SortBy,
                   sortOrder: SortOrder,
                   page: Int,
                   perPage: Int) async throws -> [Service] {
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
                return try await query.sort(\.$categoryId).range(range).all()
            case .desc:
                return try await query.sort(\.$categoryId, .descending).range(range).all()
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

/*
 //
 //  File.swift
 //
 //
 //  Created by IntrodexMac on 4/2/2567 BE.
 //

 import Foundation
 import Vapor
 import Fluent

 final class Service: Model, Content {
     static let schema = "Services"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "number")
     var number: Int
     
     @Field(key: "name")
     var name: String
     
     @Field(key: "description")
     var description: String?
     
     @Field(key: "price")
     var price: Double
     
     @Field(key: "unit")
     var unit: String
     
     @Field(key: "category_id")
     var categoryId: UUID?
     
     @Field(key: "images")
     var images: [String]
     
     @Field(key: "cover_image")
     var coverImage: String?
     
     @Field(key: "tags")
     var tags: [String]
     
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
          number: Int,
          name: String,
          description: String?,
          price: Double = 0,
          unit: String = "",
          categoryId: UUID? = nil,
          images: [String] = [],
          coverImage: String? = nil,
          tags: [String] = [],
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil) {
         self.id = id ?? .init()
         self.number = number
         self.name = name
         self.description = description
         self.price = price
         self.unit = unit
         self.categoryId = categoryId
         self.images = images
         self.coverImage = coverImage
         self.tags = tags
         self.createdAt = createdAt ?? Date()
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
     }
     
 }

 extension Service {
     struct Stub {
         
         static var group: [Service] {
             [
                 self.yoga,
                 self.pilates,
                 self.spinning
             ]
         }
         
         static var yoga: Service {
             .init(number: 1,
                   name: "Yoga Class",
                   description: "A one-hour yoga class focusing on relaxation and flexibility.",
                   price: 20.00,
                   unit: "hour",
                   categoryId: nil,
                   images: [
                     "https://example.com/yoga-class-image1.jpg",
                     "https://example.com/yoga-class-image2.jpg"
                   ],
                   coverImage: nil,
                   tags: [])
         }
         
         static var pilates: Service {
             .init(number: 2,
                   name: "Pilates Class",
                   description: "A one-hour pilates class focusing on core strength and flexibility.",
                   price: 25.00,
                   unit: "hour",
                   categoryId: nil,
                   images: [
                     "https://example.com/pilates-class-image1.jpg",
                     "https://example.com/pilates-class-image2.jpg"
                   ])
         }
         
         static var spinning: Service {
             .init(number: 3,
                   name: "Spinning Class",
                   description: "A one-hour spinning class focusing on cardio and endurance.",
                   price: 15.00,
                   unit: "hour",
                   categoryId: .init(),
                   images: [
                     "https://example.com/spinning-class-image1.jpg",
                     "https://example.com/spinning-class-image2.jpg"
                   ])
         }
     }
 }

 */


//class ServiceRepository: ServiceRepositoryProtocol {
//    
//    func fetchAll(req: ServiceRepository.Fetch,
//                  on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
//        do {
//            let page = req.page
//            let perPage = req.perPage
//            let sortBy = req.sortBy
//            let sortOrder = req.sortOrder
//            
//            guard page > 0, perPage > 0 else { throw DefaultError.invalidInput }
//            
//            let query = Service.query(on: db)
//            
//            if req.showDeleted {
//                query.withDeleted()
//            } else {
//                query.filter(\.$deletedAt == nil)
//            }
//            
//            let total = try await query.count()
//            let items = try await sortQuery(query: query,
//                                            sortBy: sortBy,
//                                            sortOrder: sortOrder,
//                                            page: page,
//                                            perPage: perPage)
//            
//            let responseItems = items.map { ServiceResponse(from: $0) }
//            let response = PaginatedResponse(page: page, perPage: perPage, total: total, items: responseItems)
//            
//            return response
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func create(content: ServiceRepository.Create, on db: Database) async throws -> ServiceResponse {
//        do {
//            let lastedNumber = try await fetchLastedNumber(on: db)
//            let nextNumber = lastedNumber + 1
//            let newModel = Service(number: nextNumber,
//                                   name: content.name,
//                                   description: content.description,
//                                   price: content.price,
//                                   unit: content.unit,
//                                   categoryId: content.categoryId,
//                                   images: content.images,
//                                   coverImage: content.coverImage,
//                                   tags: content.tags)
//            
//            try await newModel.save(on: db)
//            
//            return ServiceResponse(from: newModel)
//        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
//            throw CommonError.duplicateName
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func find(id: UUID, on db: Database) async throws -> ServiceResponse {
//        do {
//            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
//            
//            return ServiceResponse(from: model)
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func find(name: String, on db: Database) async throws -> ServiceResponse {
//        do {
//            guard let model = try await Service.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
//            
//            return ServiceResponse(from: model)
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> ServiceResponse {
//        do {
//            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
//            try await updateBuilder.update()
//            
//            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
//            
//            return ServiceResponse(from: model)
//        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
//            throw CommonError.duplicateName
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func delete(id: UUID, on db: Database) async throws -> ServiceResponse {
//        do {
//            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
//            
//            try await model.delete(on: db).get()
//            
//            return ServiceResponse(from: model)
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
//        do {
//            let perPage = req.perPage
//            let page = req.page
//            let keyword = req.q
//            let sort = req.sortBy
//            let order = req.sortOrder
//            
//            guard
//                keyword.count > 0,
//                perPage > 0,
//                page > 0
//            else { throw DefaultError.invalidInput }
//
//            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
//            let query = Service.query(on: db).group(.or) { or in
//                or.filter(\.$name =~ regexPattern)
//                or.filter(\.$description =~ regexPattern)
//                if let number = Int(keyword) {
//                    or.filter(\.$number == number)
//                }
//             }
//                    
//            let total = try await query.count()
//            let items = try await sortQuery(query: query,
//                                            sortBy: sort,
//                                            sortOrder: order,
//                                            page: page,
//                                            perPage: perPage)
//            let responseItems = items.map { ServiceResponse(from: $0) }
//            let response = PaginatedResponse(page: page,
//                                             perPage: perPage,
//                                             total: total,
//                                             items: responseItems)
//            
//            return response
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//
//    func fetchLastedNumber(on db: Database) async throws -> Int {
//        let query = Service.query(on: db).withDeleted()
//        query.sort(\.$number, .descending)
//        query.limit(1)
//
//        let model = try await query.first()
//        
//        return model?.number ?? 0
//    }
//}
//
//
//private extension ServiceRepository {
//    func sortQuery(query: QueryBuilder<Service>,
//                   sortBy: ServiceRepository.SortBy,
//                   sortOrder: ServiceRepository.SortOrder,
//                   page: Int,
//                   perPage: Int) async throws -> [Service] {
//        switch sortBy {
//        case .name:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .createdAt:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .number:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .price:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$price).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$price, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .categoryId:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$categoryId).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$categoryId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        }
//    }
//}
//
//extension ServiceRepository {
//    
//    static func updateFieldsBuilder(uuid: UUID, content: ServiceRepository.Update, db: Database) -> QueryBuilder<Service> {
//        let updateBuilder = Service.query(on: db).filter(\.$id == uuid)
//        
//        if let name = content.name {
//            updateBuilder.set(\.$name, to: name)
//        }
//        
//        if let description = content.description {
//            updateBuilder.set(\.$description, to: description)
//        }
//        
//        if let price = content.price {
//            updateBuilder.set(\.$price, to: price)
//        }
//        
//        if let unit = content.unit {
//            updateBuilder.set(\.$unit, to: unit)
//        }
//        
//        if let categoryId = content.categoryId {
//            updateBuilder.set(\.$categoryId, to: categoryId)
//        }
//        
//        if let images = content.images {
//            updateBuilder.set(\.$images, to: images)
//        }
//        
//        if let coverImage = content.coverImage {
//            updateBuilder.set(\.$coverImage, to: coverImage)
//        }
//        
//        if let tags = content.tags {
//            updateBuilder.set(\.$tags, to: tags)
//        }
//        
//        return updateBuilder
//    }
//    
//    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Service> {
//        return Service.query(on: db).filter(\.$id == uuid)
//    }
//}
//
