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
        
        let groups = routes.grouped("service_categories")
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
    
    // GET /service_categories?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ProductCategory> {        
        let reqContent = try req.query.decode(ProductCategoryRepository.Fetch.self)

        return try await repository.fetchAll(req: reqContent, on: req.db)
    }
    
    // POST /service_categories
    func create(req: Request) async throws -> ProductCategory {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content, on: req.db)
    }
    
    // GET /service_categories/:id
    func getByID(req: Request) async throws -> ProductCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /service_categories/:id
    func update(req: Request) async throws -> ProductCategory {
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

    // DELETE /service_categories/:id
    func delete(req: Request) async throws -> ProductCategory {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid, on: req.db)
    }
    
    // GET /service_categories/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ProductCategory> {
        let _ = try validator.validateSearchQuery(req)
        let reqContent = try req.query.decode(ProductCategoryRepository.Search.self)
        
        return try await repository.search(req: reqContent, on: req.db)        
    }
}

/*

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
*/

/*
protocol ProductCategoryValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ProductCategoryRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductCategoryRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ProductCategoryValidator: ProductCategoryValidatorProtocol {
    typealias CreateContent = ProductCategoryRepository.Create
    typealias UpdateContent = ProductCategoryRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming ProductCategory
            let content: ProductCategoryValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the ProductCategory directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductCategoryRepository.Update) {
        typealias UpdateProductCategory = ProductCategoryRepository.Update
        do {
            // Decode the incoming ProductCategory and validate it
            let content: UpdateProductCategory = try req.content.decode(UpdateProductCategory.self)
            try UpdateProductCategory.validate(content: req)
            
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
