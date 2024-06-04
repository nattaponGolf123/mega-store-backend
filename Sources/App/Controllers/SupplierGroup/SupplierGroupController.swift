import Foundation
import Fluent
import Vapor

class SupplierGroupController: RouteCollection {
    
    private(set) var repository: SupplierGroupRepositoryProtocol
    private(set) var validator: SupplierGroupValidatorProtocol
    
    init(repository: SupplierGroupRepositoryProtocol = FluentSupplierGroupRepository(),
         validator: SupplierGroupValidatorProtocol = SupplierGroupValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("supplier_groups")
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
    
    // GET /supplier_groups?show_deleted=true
    func all(req: Request) async throws -> [SupplierGroup] {
        let showDeleted = req.query["show_deleted"] == "true"
        
        return try await repository.fetchAll(showDeleted: showDeleted, on: req.db)
    }
    
    // POST /supplier_groups
    func create(req: Request) async throws -> SupplierGroup {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content, on: req.db)
    }
    
    // GET /supplier_groups/:id
    func getByID(req: Request) async throws -> SupplierGroup {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /supplier_groups/:id
    func update(req: Request) async throws -> SupplierGroup {
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

    // DELETE /supplier_groups/:id
    func delete(req: Request) async throws -> SupplierGroup {
        let uuid = try validator.validateID(req)
        
        return try await repository.delete(id: uuid, on: req.db)
    }
    
    // GET /supplier_groups/search
    func search(req: Request) async throws -> [SupplierGroup] {
        let q = try validator.validateSearchQuery(req)
        
        return try await repository.search(name: q, on: req.db)
    }
}