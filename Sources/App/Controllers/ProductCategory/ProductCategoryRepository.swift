import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ProductCategoryRepositoryProtocol {
    func fetchAll(req: ProductCategoryRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductCategory>
    func create(content: ProductCategoryRepository.Create, on db: Database) async throws -> ProductCategory
    func find(id: UUID, on db: Database) async throws -> ProductCategory
    func find(name: String, on db: Database) async throws -> ProductCategory
    func update(id: UUID, with content: ProductCategoryRepository.Update, on db: Database) async throws -> ProductCategory
    func delete(id: UUID, on db: Database) async throws -> ProductCategory
    func search(req: ProductCategoryRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductCategory>
}

class ProductCategoryRepository: ProductCategoryRepositoryProtocol {
    
    func fetchAll(req: ProductCategoryRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductCategory> {
        do {
            let page = req.page
            let perPage = req.perPage
            
            guard
                page > 0,
                perPage > 0
            else { throw DefaultError.invalidInput }
            
            let query = ProductCategory.query(on: db)
            
            if req.showDeleted {
                query.withDeleted()
            } else {
                query.filter(\.$deletedAt == nil)
            }
            
            let total = try await query.count()
            //query sorted by name
            let items = try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
            
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
    
    func create(content: ProductCategoryRepository.Create, on db: Database) async throws -> ProductCategory {
        do {
            // Initialize the ProductCategory from the validated content
            let newGroup = ProductCategory(name: content.name, description: content.description)
            
            // Attempt to save the new group to the database
            try await newGroup.save(on: db)
            
            // Return the newly created group
            return newGroup
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID, on db: Database) async throws -> ProductCategory {
        do {
            guard let group = try await ProductCategory.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return group
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ProductCategory {
        do {
            guard let group = try await ProductCategory.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID, with content: ProductCategoryRepository.Update, on db: Database) async throws -> ProductCategory {
        do {
            
            // Update the supplier group in the database
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            // Retrieve the updated supplier group
            guard let group = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func delete(id: UUID, on db: Database) async throws -> ProductCategory {
        do {
            guard let group = try await ProductCategory.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await group.delete(on: db).get()
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func search(req: ProductCategoryRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductCategory> {
        do {
            let perPage = req.perPage
            let page = req.page
            let q = req.q
            
            guard
                q.count > 0,
                perPage > 0,
                page > 0
            else { throw DefaultError.invalidInput }
            
            let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
            let query = ProductCategory.query(on: db).filter(\.$name =~ regexPattern)
            
            
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
}

extension ProductCategoryRepository {
    
    // Helper function to update supplier group fields in the database
    static func updateFieldsBuilder(uuid: UUID, content: ProductCategoryRepository.Update, db: Database) -> QueryBuilder<ProductCategory> {
        let updateBuilder = ProductCategory.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<ProductCategory> {
        return ProductCategory.query(on: db).filter(\.$id == uuid)
    }
}
