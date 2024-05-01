//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class ServiceCategoryController: RouteCollection {
    
    private(set) var repository: ServiceCategoryRepositoryProtocol
    private(set) var validator: ServiceCategoryValidatorProtocol
    
    init(repository: ServiceCategoryRepositoryProtocol = FluentServiceCategoryRepository(),
         validator: ServiceCategoryValidatorProtocol = ServiceCategoryValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let cates = routes.grouped("service_categories")
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
    
    // GET /service_categories?show_deleted=true
    func all(req: Request) async throws -> [ServiceCategory] {
        let showDeleted = req.query["show_deleted"] == "true"
        
        return try await repository.fetchAll(showDeleted: showDeleted,
                                   on: req.db)
    }
    
    // POST /service_categories
    func create(req: Request) async throws -> ServiceCategory {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content,
                                           on: req.db)
    }
    
    // GET /service_categories/:id
    func getByID(req: Request) async throws -> ServiceCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid,
                                         on: req.db)
    }
    
    // PUT /service_categories/:id
    func update(req: Request) async throws -> ServiceCategory {
        let (uuid, content) = try validator.validateUpdate(req)
        
        return try await repository.update(id: uuid,
                                           with: content,
                                           on: req.db)
    }

    // DELETE /service_categories/:id
    func delete(req: Request) async throws -> ServiceCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid,
                                           on: req.db)
    }
    
    // GET /service_categories/search
    func search(req: Request) async throws -> [ServiceCategory] {
        let q = try validator.validateSearchQuery(req)
        
        return try await repository.search(name: q,
                                          on: req.db)
    }
    
}
