import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ServiceRepositoryProtocol {
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ServiceResponse>
    func create(content: ServiceRepository.Create, on db: Database) async throws -> ServiceResponse
    func find(id: UUID, on db: Database) async throws -> ServiceResponse
    func find(name: String, on db: Database) async throws -> ServiceResponse
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> ServiceResponse
    func delete(id: UUID, on db: Database) async throws -> ServiceResponse
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse>
    func fetchLastedNumber(on db: Database) async throws -> Int
}

class ServiceRepository: ServiceRepositoryProtocol {
    
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
        do {
            let page = req.page
            let perPage = req.perPage
            let sortBy = req.sortBy
            let sortOrderBy = req.sortByOrder
            
            guard page > 0, perPage > 0 else { throw DefaultError.invalidInput }
            
            let query = Service.query(on: db)
            
            if req.showDeleted {
                query.withDeleted()
            } else {
                query.filter(\.$deletedAt == nil)
            }
            
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sortBy,
                                            sortOrderBy: sortOrderBy,
                                            page: page,
                                            perPage: perPage)
            
            let responseItems = items.map { ServiceResponse(from: $0) }
            let response = PaginatedResponse(page: page, perPage: perPage, total: total, items: responseItems)
            
            return response
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func create(content: ServiceRepository.Create, on db: Database) async throws -> ServiceResponse {
        do {
            let lastedNumber = try await fetchLastedNumber(on: db)
            let nextNumber = lastedNumber + 1
            let newModel = Service(number: nextNumber,
                                   name: content.name,
                                   description: content.description,
                                   price: content.price,
                                   unit: content.unit,
                                   categoryId: content.categoryId,
                                   images: content.images,
                                   coverImage: content.coverImage,
                                   tags: content.tags)
            
            try await newModel.save(on: db)
            
            return ServiceResponse(from: newModel)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID, on db: Database) async throws -> ServiceResponse {
        do {
            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return ServiceResponse(from: model)
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ServiceResponse {
        do {
            guard let model = try await Service.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return ServiceResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> ServiceResponse {
        do {
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return ServiceResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func delete(id: UUID, on db: Database) async throws -> ServiceResponse {
        do {
            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await model.delete(on: db).get()
            
            return ServiceResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
        do {
            let perPage = req.perPage
            let page = req.page
            let keyword = req.q
            let sort = req.sortBy
            let order = req.sortByOrder
            
            guard
                keyword.count > 0,
                perPage > 0,
                page > 0
            else { throw DefaultError.invalidInput }

            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
            let query = Service.query(on: db).group(.or) { or in
                or.filter(\.$name =~ regexPattern)
                or.filter(\.$description =~ regexPattern)
                if let number = Int(keyword) {
                    or.filter(\.$number == number)
                }
             }
                    
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sort,
                                            sortOrderBy: order,
                                            page: page,
                                            perPage: perPage)
            let responseItems = items.map { ServiceResponse(from: $0) }
            let response = PaginatedResponse(page: page,
                                             perPage: perPage,
                                             total: total,
                                             items: responseItems)
            
            return response
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func fetchLastedNumber(on db: Database) async throws -> Int {
        let query = Service.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)

        let model = try await query.first()
        
        return model?.number ?? 0
    }
}


private extension ServiceRepository {
    func sortQuery(query: QueryBuilder<Service>,
                   sortBy: ServiceRepository.SortBy,
                   sortOrderBy: ServiceRepository.SortByOrder,
                   page: Int,
                   perPage: Int) async throws -> [Service] {
        switch sortBy {
        case .name:
            switch sortOrderBy {
            case .asc:
                return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .createdAt:
            switch sortOrderBy {
            case .asc:
                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .number:
            switch sortOrderBy {
            case .asc:
                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .price:
            switch sortOrderBy {
            case .asc:
                return try await query.sort(\.$price).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$price, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .categoryId:
            switch sortOrderBy {
            case .asc:
                return try await query.sort(\.$categoryId).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$categoryId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        }
    }
}

extension ServiceRepository {
    
    static func updateFieldsBuilder(uuid: UUID, content: ServiceRepository.Update, db: Database) -> QueryBuilder<Service> {
        let updateBuilder = Service.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        if let price = content.price {
            updateBuilder.set(\.$price, to: price)
        }
        
        if let unit = content.unit {
            updateBuilder.set(\.$unit, to: unit)
        }
        
        if let categoryId = content.categoryId {
            updateBuilder.set(\.$categoryId, to: categoryId)
        }
        
        if let images = content.images {
            updateBuilder.set(\.$images, to: images)
        }
        
        if let coverImage = content.coverImage {
            updateBuilder.set(\.$coverImage, to: coverImage)
        }
        
        if let tags = content.tags {
            updateBuilder.set(\.$tags, to: tags)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Service> {
        return Service.query(on: db).filter(\.$id == uuid)
    }
}

