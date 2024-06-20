import Foundation
import Fluent
import Vapor

class ProductController: RouteCollection {
    
    private(set) var repository: ProductRepositoryProtocol
    private(set) var validator: ProductValidatorProtocol
    
    init(repository: ProductRepositoryProtocol = ProductRepository(),
         validator: ProductValidatorProtocol = ProductValidator()) {
        self.repository = repository
        self.validator = validator
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

            withID.group("contacts") { withContact in
                withContact.post(use: addContact)
                withContact.delete(use: reomveContact)

                withContact.group(":contact_id") { withContactID in
                    withContactID.delete(use: reomveContact)
                }
            }
        }
        
        groups.group("search") { withSearch in
            withSearch.get(use: search)
        }
    }
    
    // GET /products?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ProductResponse> {
        let reqContent = try req.query.decode(ProductRepository.Fetch.self)

        return try await repository.fetchAll(req: reqContent, on: req.db)
    }
    
    // POST /products
    func create(req: Request) async throws -> ProductResponse {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content, on: req.db)
    }
    
    // GET /products/:id
    func getByID(req: Request) async throws -> ProductResponse {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /products/:id
    func update(req: Request) async throws -> ProductResponse {
        let (uuid, content) = try validator.validateUpdate(req)
        
        do {
            // check if name is duplicate
            guard let name = content.name else { throw DefaultError.invalidInput }
            
            let _ = try await repository.find(name: name, on: req.db)
            
            throw CommonError.duplicateName
            
        } catch let error as DefaultError {
            switch error {
            case .notFound: // no duplicate
                return try await repository.update(id: uuid, with: content, on: req.db)
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

    // DELETE /products/:id
    func delete(req: Request) async throws -> ProductResponse {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid, on: req.db)
    }
    
    // GET /products/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ProductResponse> {
        let _ = try validator.validateSearchQuery(req)
        let reqContent = try req.query.decode(ProductRepository.Search.self)
        
        return try await repository.search(req: reqContent, on: req.db)        
    }

    // POST /products/:id/variants
    func createVariant(req: Request) async throws -> ProductResponse {
        let (uuid, content) = try validator.validateCreateVariant(req)
        
        return try await repository.createVariant(id: uuid, content: content, on: req.db)
    }

    // PUT /products/:id/variants/:variant_id
    func updateVariant(req: Request) async throws -> ProductResponse {
        let (uuid, variantId, content) = try validator.validateUpdateVariant(req)
        
        return try await repository.updateVariant(id: uuid, variantId: variantId, with: content, on: req.db)
    }

    // DELETE /products/:id/variants/:variant_id
    func deleteVariant(req: Request) async throws -> ProductResponse {
        let (uuid, variantId) = try validator.validateDeleteVariant(req)
        
        return try await repository.deleteVariant(id: uuid, variantId: variantId, on: req.db)
    }

    // POST /products/:id/contacts
    func addContact(req: Request) async throws -> ProductResponse {
        let (uuid, contactId) = try validator.validateAddContact(req)
        
        return try await repository.linkContact(id: uuid, contactId: contactId, on: req.db)
    }

    // DELETE /products/:id/contacts/:contact_id
    func reomveContact(req: Request) async throws -> ProductResponse {
        let (uuid, contactId) = try validator.validateRemoveContact(req)
        
        return try await repository.deleteContact(id: uuid, contactId: contactId, on: req.db)
    }
    
}

/*
protocol ProductRepositoryProtocol {
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func create(content: ProductRepository.Create, on db: Database) async throws -> ProductResponse
    func find(id: UUID, on db: Database) async throws -> ProductResponse
    func find(name: String, on db: Database) async throws -> ProductResponse
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> ProductResponse
    func delete(id: UUID, on db: Database) async throws -> ProductResponse
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func linkContact(id: UUID, contactId: UUID, on db: Database) async throws -> ProductResponse
    func deleteContact(id: UUID, contactId: UUID, on db: Database) async throws -> ProductResponse
    func fetchLastedNumber(on db: Database) async throws -> Int
    
    func fetchVariantLastedNumber(id: UUID, on db: Database) async throws -> Int
    func createVariant(id: UUID, content: ProductRepository.CreateVariant, on db: Database) async throws -> ProductResponse
    func updateVariant(id: UUID, variantId: UUID, with content: ProductRepository.UpdateVariant, on db: Database) async throws -> ProductResponse
    func deleteVariant(id: UUID, variantId: UUID, on db: Database) async throws -> ProductResponse    

}

*/
