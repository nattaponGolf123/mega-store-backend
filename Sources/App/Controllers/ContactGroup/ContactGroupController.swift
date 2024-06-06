import Foundation
import Fluent
import Vapor

class ContactGroupController: RouteCollection {
    
    private(set) var repository: ContactGroupRepositoryProtocol
    private(set) var validator: ContactGroupValidatorProtocol
    
    init(repository: ContactGroupRepositoryProtocol = ContactGroupRepository(),
         validator: ContactGroupValidatorProtocol = ContactGroupValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("contact_groups")
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
    
    // GET /contact_groups?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ContactGroup> {        
        let reqContent = try req.query.decode(ContactGroupRepository.Fetch.self)

        return try await repository.fetchAll(req: reqContent, on: req.db)
    }
    
    // POST /contact_groups
    func create(req: Request) async throws -> ContactGroup {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content, on: req.db)
    }
    
    // GET /contact_groups/:id
    func getByID(req: Request) async throws -> ContactGroup {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /contact_groups/:id
    func update(req: Request) async throws -> ContactGroup {
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

    // DELETE /contact_groups/:id
    func delete(req: Request) async throws -> ContactGroup {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid, on: req.db)
    }
    
    // GET /contact_groups/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ContactGroup> {
        let _ = try validator.validateSearchQuery(req)
        let reqContent = try req.query.decode(ContactGroupRepository.Search.self)
        
        return try await repository.search(req: reqContent, on: req.db)        
    }
}

/*

protocol ContactGroupRepositoryProtocol {
    func fetchAll(req: ContactGroupRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ContactGroup>
    func create(content: ContactGroupRepository.Create, on db: Database) async throws -> ContactGroup
    func find(id: UUID, on db: Database) async throws -> ContactGroup
    func find(name: String, on db: Database) async throws -> ContactGroup
    func update(id: UUID, with content: ContactGroupRepository.Update, on db: Database) async throws -> ContactGroup
    func delete(id: UUID, on db: Database) async throws -> ContactGroup
    func search(req: ContactGroupRepository.Search, on db: Database) async throws -> PaginatedResponse<ContactGroup>
}
*/

/*
protocol ContactGroupValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactGroupRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactGroupRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ContactGroupValidator: ContactGroupValidatorProtocol {
    typealias CreateContent = ContactGroupRepository.Create
    typealias UpdateContent = ContactGroupRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming ContactGroup
            let content: ContactGroupValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the ContactGroup directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactGroupRepository.Update) {
        typealias UpdateContactGroup = ContactGroupRepository.Update
        do {
            // Decode the incoming ContactGroup and validate it
            let content: UpdateContactGroup = try req.content.decode(UpdateContactGroup.self)
            try UpdateContactGroup.validate(content: req)
            
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
