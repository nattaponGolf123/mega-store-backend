import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ProductRepositoryProtocol {
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func create(content: ProductRepository.Create, on db: Database) async throws -> ProductResponse
    func find(id: UUID, on db: Database) async throws -> ProductResponse
    func find(name: String, on db: Database) async throws -> ProductResponse
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> ProductResponse
    func delete(id: UUID, on db: Database) async throws -> ProductResponse
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func fetchLastedNumber(on db: Database) async throws -> Int
}

class ProductRepository: ProductRepositoryProtocol {
    
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductResponse> {
        do {
            let page = req.page
            let perPage = req.perPage
            let sortBy = req.sortBy
            let sortOrder = req.sortOrder
            
            guard page > 0, perPage > 0 else { throw DefaultError.invalidInput }
            
            let query = Product.query(on: db)
            
            if req.showDeleted {
                query.withDeleted()
            } else {
                query.filter(\.$deletedAt == nil)
            }
            
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder,
                                            page: page,
                                            perPage: perPage)
            
            let responseItems = items.map { ProductResponse(from: $0) }
            let response = PaginatedResponse(page: page, perPage: perPage, total: total, items: responseItems)
            
            return response
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func create(content: ProductRepository.Create, on db: Database) async throws -> ProductResponse {
        do {
            let lastedNumber = try await fetchLastedNumber(on: db)
            let nextNumber = lastedNumber + 1
            let newModel = Product(number: nextNumber,
                                   name: content.name,
                                   description: content.description, 
                                   price: content.price,
                                   images: content.images)
            
            try await newModel.save(on: db)
            
            return ProductResponse(from: newModel)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> ProductResponse {
        do {
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func delete(id: UUID, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await model.delete(on: db).get()
            
            return ProductResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductResponse> {
        do {
            let perPage = req.perPage
            let page = req.page
            let keyword = req.q
            let sort = req.sortBy
            let order = req.sortOrder
            
            guard
                keyword.count > 0,
                perPage > 0,
                page > 0
            else { throw DefaultError.invalidInput }

            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
            let query = Product.query(on: db).group(.or) { or in
                or.filter(\.$name =~ regexPattern)
                or.filter(\.$description =~ regexPattern)
                if let number = Int(keyword) {
                    or.filter(\.$number == number)
                }
             }
                    
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sort,
                                            sortOrder: order,
                                            page: page,
                                            perPage: perPage)
            let responseItems = items.map { ProductResponse(from: $0) }
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
        let query = Product.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)

        let model = try await query.first()
        
        return model?.number ?? 0
    }
}


private extension ProductRepository {
    func sortQuery(query: QueryBuilder<Product>,
                   sortBy: ProductRepository.SortBy,
                   sortOrder: ProductRepository.SortOrder,
                   page: Int,
                   perPage: Int) async throws -> [Product] {
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
        case .number:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .price:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$price).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$price, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .categoryId:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$categoryId).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$categoryId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        }
    }
}

extension ProductRepository {
    
    static func updateFieldsBuilder(uuid: UUID, content: ProductRepository.Update, db: Database) -> QueryBuilder<Product> {
        let updateBuilder = Product.query(on: db).filter(\.$id == uuid)
        
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
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Product> {
        return Product.query(on: db).filter(\.$id == uuid)
    }
}

