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
        }
        
        groups.group("search") { _search in
            _search.get(use: search)
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
}

/*

protocol ProductRepositoryProtocol {
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<Product>
    func create(content: ProductRepository.Create, on db: Database) async throws -> Product
    func find(id: UUID, on db: Database) async throws -> Product
    func find(name: String, on db: Database) async throws -> Product
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> Product
    func delete(id: UUID, on db: Database) async throws -> Product
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<Product>
}
*/

/*
protocol ProductValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ProductRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ProductValidator: ProductValidatorProtocol {
    typealias CreateContent = ProductRepository.Create
    typealias UpdateContent = ProductRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming Product
            let content: ProductValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the Product directly
            try CreateContent.validate(content: req)
            
            return content
        } catch let error as ValidationsError {
            // Parse and throw a more specific input validation error if validation fails
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            // Handle all other errors
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductRepository.Update) {
        typealias UpdateProduct = ProductRepository.Update
        do {
            // Decode the incoming Product and validate it
            let content: UpdateProduct = try req.content.decode(UpdateProduct.self)
            try UpdateProduct.validate(content: req)
            
            // Extract the ID from the request's parameters
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id"), let uuid = UUID(id) else { throw DefaultError.invalidInput }
        
        return uuid
    }

    func validateSearchQuery(_ req: Request) throws -> String {
        guard let search = req.query[String.self, at: "q"] else { throw DefaultError.invalidInput }
        
        return search
    }
}
*/
