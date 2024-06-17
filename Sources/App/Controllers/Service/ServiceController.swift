import Foundation
import Fluent
import Vapor

class ServiceController: RouteCollection {
    
    private(set) var repository: ServiceRepositoryProtocol
    private(set) var validator: ServiceValidatorProtocol
    
    init(repository: ServiceRepositoryProtocol = ServiceRepository(),
         validator: ServiceValidatorProtocol = ServiceValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("services")
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
    
    // GET /services?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ServiceResponse> {
        let reqContent = try req.query.decode(ServiceRepository.Fetch.self)

        return try await repository.fetchAll(req: reqContent, on: req.db)
    }
    
    // POST /services
    func create(req: Request) async throws -> ServiceResponse {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content, on: req.db)
    }
    
    // GET /services/:id
    func getByID(req: Request) async throws -> ServiceResponse {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /services/:id
    func update(req: Request) async throws -> ServiceResponse {
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

    // DELETE /services/:id
    func delete(req: Request) async throws -> ServiceResponse {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid, on: req.db)
    }
    
    // GET /services/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ServiceResponse> {
        let _ = try validator.validateSearchQuery(req)
        let reqContent = try req.query.decode(ServiceRepository.Search.self)
        
        return try await repository.search(req: reqContent, on: req.db)        
    }
}

/*

protocol ServiceRepositoryProtocol {
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<Service>
    func create(content: ServiceRepository.Create, on db: Database) async throws -> Service
    func find(id: UUID, on db: Database) async throws -> Service
    func find(name: String, on db: Database) async throws -> Service
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> Service
    func delete(id: UUID, on db: Database) async throws -> Service
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<Service>
}
*/

/*
protocol ServiceValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ServiceRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ServiceRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ServiceValidator: ServiceValidatorProtocol {
    typealias CreateContent = ServiceRepository.Create
    typealias UpdateContent = ServiceRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming Service
            let content: ServiceValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the Service directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ServiceRepository.Update) {
        typealias UpdateService = ServiceRepository.Update
        do {
            // Decode the incoming Service and validate it
            let content: UpdateService = try req.content.decode(UpdateService.self)
            try UpdateService.validate(content: req)
            
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
