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
        let content = try req.query.decode(ContactGroupRequest.FetchAll.self)

        return try await repository.fetchAll(request: content,
                                             on: req.db)
    }
    
    // POST /contact_groups
    func create(req: Request) async throws -> ContactGroup {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(request: content,
                                           on: req.db)
    }
    
    // GET /contact_groups/:id
    func getByID(req: Request) async throws -> ContactGroup {
        let content = try validator.validateID(req)
        
        return try await repository.fetchById(request: content,
                                              on: req.db)
    }
    
    // PUT /contact_groups/:id
    func update(req: Request) async throws -> ContactGroup {
        let (id, content) = try validator.validateUpdate(req)
        
        return try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
        
//        do {
//            // check if name is duplicate
//            guard let name = content.name else { throw DefaultError.invalidInput }
//            
//            let _ = try await repository.find(name: name, on: req.db)
//            
//            throw CommonError.duplicateName
//            
//        } catch let error as DefaultError {
//            switch error {
//            case .notFound: // no duplicate
//                return try await repository.update(id: uuid, with: content, on: req.db)
//            default:
//                throw error
//            }
//            
//        } catch let error as CommonError {
//            throw error
//            
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
    }

    // DELETE /contact_groups/:id
    func delete(req: Request) async throws -> ContactGroup {
        let id = try validator.validateID(req)
        
        return try await repository.delete(byId: id,
                                           on: req.db)
    }
    
    // GET /contact_groups/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ContactGroup> {
        
        let content = try validator.validateSearchQuery(req)
        
        return try await repository.searchByName(request: content,
                                                 on: req.db)
//        let _ = try validator.validateSearchQuery(req)
//        let reqContent = try req.query.decode(ContactGroupRequest.Search.self)
//        
//        return try await repository.search(req: reqContent, on: req.db)        
    }
}
