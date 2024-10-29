import Fluent
import Foundation
import Vapor

class ContactGroupController: RouteCollection {

    private(set) var repository: ContactGroupRepositoryProtocol
    private(set) var validator: ContactGroupValidatorProtocol

    init(repository: ContactGroupRepositoryProtocol = ContactGroupRepository(),
         validator: ContactGroupValidatorProtocol = ContactGroupValidator())
    {
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
    }

    // GET /contact_groups
    func all(req: Request) async throws -> [ContactGroupResponse] {
        let content = try req.query.decode(ContactGroupRequest.FetchAll.self)

        let groups = try await repository.fetchAll(request: content,
                                             on: req.db)
        return groups.map { ContactGroupResponse(from: $0) }
    }

    // POST /contact_groups
    func create(req: Request) async throws -> Response {
        let content = try validator.validateCreate(req)

        let group = try await repository.create(request: content,
                                                on: req.db)

        let response = ContactGroupResponse(from: group)

        return try Response(status: .created,
                            headers: ["Content-Type": "application/json"],
                            body: .init(data: JSONEncoder().encode(response)))
    }

    // GET /contact_groups/:id
    func getByID(req: Request) async throws -> ContactGroupResponse {
        let content = try validator.validateID(req)

        let group = try await repository.fetchById(request: content,
                                              on: req.db)
        return ContactGroupResponse(from: group)
    }

    // PUT /contact_groups/:id
    func update(req: Request) async throws -> ContactGroupResponse {
        let (id, content) = try validator.validateUpdate(req)

        let group = try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
        return ContactGroupResponse(from: group)
    }

    // DELETE /contact_groups/:id
    func delete(req: Request) async throws -> ContactGroupResponse {
        let id = try validator.validateID(req)

        let group = try await repository.delete(byId: id,
                                           on: req.db)
        return ContactGroupResponse(from: group)
    }

}
