//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class ProductCategoryController: RouteCollection {
    
    private(set) var repository: ProductCategoryRepositoryProtocol
    private(set) var validator: ProductCategoryValidatorProtocol
    
    init(repository: ProductCategoryRepositoryProtocol = FluentProductCategoryRepository(),
         validator: ProductCategoryValidatorProtocol = ProductCategoryValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let cates = routes.grouped("product_categories")
        cates.get(use: all)
        cates.post(use: create)
        
        cates.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            withID.delete(use: delete)
        }
        
        cates.group("search") { _search in
            _search.get(use: search)
        }
    }
    
    // GET /product_categories?show_deleted=true
    func all(req: Request) async throws -> [ProductCategory] {
        let showDeleted = req.query["show_deleted"] == "true"
        
        return try await repository.fetchAll(showDeleted: showDeleted,
                                   on: req.db)
    }
    
    // POST /product_categories
    func create(req: Request) async throws -> ProductCategory {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content,
                                           on: req.db)
        
//        do {
//            // Decode the incoming content
//            let content = try req.content.decode(Self.CreateContent.self)
//
//            // Validate the content directly
//            try Self.CreateContent.validate(content: req)
//            
//            return try await repository.create(content: content,
//                                               on: req.db)
//        } catch let error as ValidationsError {
//            // Parse and throw a more specific input validation error if validation fails
//            let errors = InputError.parse(failures: error.failures)
//            throw InputValidateError.inputValidateFailed(errors: errors)
//        } catch let error as DecodingError {
//            // Handle JSON decoding errors
//            print(error)
//            throw DefaultError.invalidInput
//        } catch let error as FluentError {
//            // Handle Fluent specific errors, e.g., model not found
//            print(error)
//            throw DefaultError.dbConnectionError
//        } catch {
//            // Handle all other errors
//            throw DefaultError.serverError
//        }
    }
    
    // GET /product_categories/:id
    func getByID(req: Request) async throws -> ProductCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid,
                                         on: req.db)
    }
    
    // PUT /product_categories/:id
    func update(req: Request) async throws -> ProductCategory {
        let (uuid, content) = try validator.validateUpdate(req)
        
        return try await repository.update(id: uuid,
                                           with: content,
                                           on: req.db)
//        do {
//            // Decode the incoming content and validate it
//            let content = try req.content.decode(Self.UpdateContent.self)
//            try Self.UpdateContent.validate(content: req)
//            
//            // Extract the ID from the request's parameters
//            guard let id = req.parameters.get("id", as: UUID.self) else {
//                throw DefaultError.invalidInput
//            }
//            
//            return try await repository.update(id: id,
//                                               with: content,
//                                               on: req.db)
//        } catch let error as ValidationsError {
//            let errors = InputError.parse(failures: error.failures)
//            throw InputValidateError.inputValidateFailed(errors: errors)
//        } catch let error as FluentError {
//            print(error)
//            throw DefaultError.dbConnectionError
//        } catch {
//            throw DefaultError.serverError
//        }
    }

    // DELETE /product_categories/:id
    func delete(req: Request) async throws -> ProductCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid,
                                           on: req.db)
//        guard
//            let id = req.parameters.get("id"),
//            let uuid = UUID(id)
//        else { throw DefaultError.invalidInput }
//        
//        return try await repository.delete(id: uuid,
//                                           on: req.db)
    }
    
    // GET /product_categories/search
    func search(req: Request) async throws -> [ProductCategory] {
        let q = try validator.validateSearchQuery(req)
        
        return try await repository.search(name: q,
                                          on: req.db)
//        guard
//            let search = req.query[String.self,
//                                   at: "q"]
//        else { throw DefaultError.invalidInput }
//        
//        return try await repository.search(name: search,
//                                          on: req.db)
    }
    
}
