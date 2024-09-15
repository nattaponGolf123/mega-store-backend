import Foundation
import Fluent
import Vapor

class ServiceController: RouteCollection {
    
    typealias FetchAll = GeneralRequest.FetchAll
    
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
        let reqContent = try req.query.decode(FetchAll.self)

        let pageResponse = try await repository.fetchAll(request: reqContent,
                                                         on: req.db)
                     
        let responseItems: [ServiceResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
    
    // POST /services
    func create(req: Request) async throws -> ServiceResponse {
        let content = try validator.validateCreate(req)
        
        let service = try await repository.create(request: content,
                                                  on: req.db)
        return .init(from: service)
    }
    
    // GET /services/:id
    func getByID(req: Request) async throws -> ServiceResponse {
        let content = try validator.validateID(req)
        
        let service = try await repository.fetchById(request: content,
                                                     on: req.db)
        return .init(from: service)
    }
    
    // PUT /services/:id
    func update(req: Request) async throws -> ServiceResponse {
        let (id, content) = try validator.validateUpdate(req)
        
        let service = try await repository.update(byId: id,
                                                  request: content,
                                                  on: req.db)
        return .init(from: service)
    }
    
    // DELETE /services/:id
    func delete(req: Request) async throws -> ServiceResponse {
        let content = try validator.validateID(req)
        
        let service = try await repository.delete(byId: content,
                                           on: req.db)
        return .init(from: service)
    }
    
    // GET /services/search?name=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ServiceResponse> {
        let content = try validator.validateSearchQuery(req)
        
        let pageResponse = try await repository.search(request: content, on: req.db)
        
        let responseItems: [ServiceResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
}
