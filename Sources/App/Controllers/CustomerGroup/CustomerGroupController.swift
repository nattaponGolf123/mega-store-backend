import Foundation
import Fluent
import Vapor

class CustomerGroupController: RouteCollection {
    
    typealias FetchAll = GeneralRequest.FetchAll
    
    private(set) var repository: CustomerGroupRepositoryProtocol
    private(set) var validator: CustomerGroupValidatorProtocol
    
    init(repository: CustomerGroupRepositoryProtocol = CustomerGroupRepository(),
         validator: CustomerGroupValidatorProtocol = CustomerGroupValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        
        let groups = routes.grouped("customer_group")
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
    
    // GET /customer_group?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<CustomerGroup> {        
        let content = try req.query.decode(FetchAll.self)
        
        return try await repository.fetchAll(request: content,
                                             on: req.db)
    }
    
    // POST /customer_group
    func create(req: Request) async throws -> CustomerGroup {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(request: content,
                                           on: req.db)
    }
    
    // GET /customer_group/:id
    func getByID(req: Request) async throws -> CustomerGroup {
        let content = try validator.validateID(req)
        
        return try await repository.fetchById(request: content,
                                              on: req.db)
    }
    
    // PUT /customer_group/:id
    func update(req: Request) async throws -> CustomerGroup {
        let (id, content) = try validator.validateUpdate(req)
        
        return try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
    }

    // DELETE /customer_group/:id
    func delete(req: Request) async throws -> CustomerGroup {
        let id = try validator.validateID(req)
        
        return try await repository.delete(byId: id,
                                           on: req.db)
    }
    
    // GET /customer_group/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<CustomerGroup> {
        let content = try validator.validateSearchQuery(req)
        
        return try await repository.searchByName(request: content,
                                                 on: req.db)
    }
}
