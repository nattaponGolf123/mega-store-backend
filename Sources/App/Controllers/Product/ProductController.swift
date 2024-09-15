import Foundation
import Fluent
import Vapor

class ProductController: RouteCollection {
    
    typealias FetchAll = GeneralRequest.FetchAll
    
    private(set) var repository: ProductRepositoryProtocol
    private(set) var validator: ProductValidatorProtocol
    private(set) var generalValidator: GeneralValidatorProtocol
    
    init(repository: ProductRepositoryProtocol = ProductRepository(),
         validator: ProductValidatorProtocol = ProductValidator(),
         generalValidator: GeneralValidatorProtocol = GeneralValidator()) {
        self.repository = repository
        self.validator = validator
        self.generalValidator = generalValidator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("products")
        groups.get(use: all)
        groups.post(use: create)
        
        groups.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            withID.delete(use: delete)
            
            withID.group("variants") { withVariant in
                withVariant.post(use: createVariant)
                
                withVariant.group(":variant_id") { withVariantID in
                    withVariantID.put(use: updateVariant)
                    withVariantID.delete(use: deleteVariant)
                }
            }
        }
        
        groups.group("search") { withSearch in
            withSearch.get(use: search)
        }
    }
    
    // GET /products?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ProductResponse> {
        let reqContent = try req.query.decode(FetchAll.self)
        
        let pageResponse = try await repository.fetchAll(request: reqContent,
                                                         on: req.db)
        
        let responseItems: [ProductResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
    
    // POST /products
    func create(req: Request) async throws -> ProductResponse {
        let content = try validator.validateCreate(req)
        
        let product = try await repository.create(request: content,
                                                  on: req.db)
        
        return .init(from: product)
    }
    
    // GET /products/:id
    func getByID(req: Request) async throws -> ProductResponse {
        let content = try generalValidator.validateID(req)
        
        let product = try await repository.fetchById(request: content,
                                                     on: req.db)
        return .init(from: product)
    }
    
    // PUT /products/:id
    func update(req: Request) async throws -> ProductResponse {
        let (id, content) = try validator.validateUpdate(req)
        
        let product = try await repository.update(byId: id,
                                                  request: content,
                                                  on: req.db)
        return .init(from: product)
    }
    
    // DELETE /products/:id
    func delete(req: Request) async throws -> ProductResponse {
        let id = try generalValidator.validateID(req)
        
        let product = try await repository.delete(byId: id,
                                                  on: req.db)
        return .init(from: product)
    }
    
    // GET /products/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ProductResponse> {
        let content = try generalValidator.validateSearchQuery(req)
        
        let pageResponse = try await repository.search(request: content, on: req.db)
        
        let responseItems: [ProductResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
    
    // POST /products/:id/variants
    func createVariant(req: Request) async throws -> ProductResponse {
        let (id, content) = try validator.validateCreateVariant(req)
        
        let product = try await repository.createVariant(byId: id,
                                                         request: content,
                                                         on: req.db)
        return .init(from: product)
    }
    
    // PUT /products/:id/variants/:variant_id
    func updateVariant(req: Request) async throws -> ProductResponse {
        let (id, variantId, content) = try validator.validateUpdateVariant(req)
        
        let product = try await repository.updateVariant(byId: id,
                                                         variantId: variantId,
                                                         request: content,
                                                         on: req.db)
        return .init(from: product)
    }
    
    // DELETE /products/:id/variants/:variant_id
    func deleteVariant(req: Request) async throws -> ProductResponse {
        let (id, variantId) = try validator.validateDeleteVariant(req)
        
        let product = try await repository.deleteVariant(byId: id,
                                                         variantId: variantId,
                                                         on: req.db)
        return .init(from: product)
    }
    
}

