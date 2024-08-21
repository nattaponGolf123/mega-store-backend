import Foundation
import Fluent
import Vapor

class ProductCategoryController: RouteCollection {
    
    typealias FetchAll = GeneralRequest.FetchAll
    
    private(set) var repository: ProductCategoryRepositoryProtocol
    private(set) var validator: ProductCategoryValidatorProtocol
    
    init(repository: ProductCategoryRepositoryProtocol = ProductCategoryRepository(),
         validator: ProductCategoryValidatorProtocol = ProductCategoryValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("product_categories")
        groups.get(use: all)
        groups.post(use: create)
        
        groups.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            withID.delete(use: delete)
        }
        
        groups.group("search") { _search in
            _search.get(use: search)
        }
    }
    
    // GET /product_categories?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ProductCategory> {        
        let content = try req.query.decode(FetchAll.self)
        
        return try await repository.fetchAll(request: content,
                                             on: req.db)
    }
    
    // POST /product_categories
    func create(req: Request) async throws -> ProductCategory {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(request: content,
                                           on: req.db)
    }
    
    // GET /product_categories/:id
    func getByID(req: Request) async throws -> ProductCategory {
        let content = try validator.validateID(req)
        
        return try await repository.fetchById(request: content,
                                              on: req.db)
    }
    
    // PUT /product_categories/:id
    func update(req: Request) async throws -> ProductCategory {
        let (id, content) = try validator.validateUpdate(req)
        
        return try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
    }

    // DELETE /product_categories/:id
    func delete(req: Request) async throws -> ProductCategory {
        let id = try validator.validateID(req)
        
        return try await repository.delete(byId: id,
                                           on: req.db)
    }
    
    // GET /product_categories/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ProductCategory> {
        let content = try validator.validateSearchQuery(req)
        
        return try await repository.searchByName(request: content,
                                                 on: req.db)
    }
}
