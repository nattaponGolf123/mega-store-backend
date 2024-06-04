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
    
    init(repository: ProductCategoryRepositoryProtocol = ProductCategoryRepository(),
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
         
        do {
            // check is duplicate name
            guard
                let name = content.name 
            else { throw DefaultError.invalidInput }
            
            let _ = try await repository.find(name: name,
                                              on: req.db)
            
            throw CommonError.duplicateName
            
        } catch let error as DefaultError {
            switch error {
            case .notFound: // no duplicte
                return try await repository.update(id: uuid,
                                                   with: content,
                                                   on: req.db)
            default:
                throw error
            }
            
        } catch let error as CommonError {
            throw error
            
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    // DELETE /product_categories/:id
    func delete(req: Request) async throws -> ProductCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid,
                                           on: req.db)
    }
    
    // GET /product_categories/search
    func search(req: Request) async throws -> [ProductCategory] {
        let q = try validator.validateSearchQuery(req)
        
        return try await repository.search(name: q,
                                          on: req.db)
    }
    
}
