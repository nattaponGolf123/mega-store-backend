import Fluent
import Foundation
import Vapor

class ContactController: RouteCollection {
    typealias FetchAll = GeneralRequest.FetchAll

    private(set) var repository: ContactRepositoryProtocol
    private(set) var groupRepository: ContactGroupRepositoryProtocol
    private(set) var validator: ContactValidatorProtocol

    init(repository: ContactRepositoryProtocol = ContactRepository(),
         groupRepository: ContactGroupRepositoryProtocol = ContactGroupRepository(),
         validator: ContactValidatorProtocol = ContactValidator())
    {
        self.repository = repository
        self.groupRepository = groupRepository
        self.validator = validator
    }

    func boot(routes: RoutesBuilder) throws {
        let contacts = routes.grouped("contacts")
        contacts.get(use: all)
        contacts.post(use: create)

        contacts.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)

            // PUT /contacts/:id/businese_address/:address_id
            withID.group("businese_address") { bussineseAddress in
                bussineseAddress.grouped(":address_id").put(use: updateBussineseAddress)
            }

            // PUT /contacts/:id/shipping_address/:address_id
            withID.group("shipping_address") { shippingAddress in
                shippingAddress.grouped(":address_id").put(use: updateShippingAddress)
            }

            // DELETE /contacts/:id
            withID.delete(use: delete)
        }

        contacts.group("search") { _search in
            _search.get(use: search)
        }

        contacts.group("group") { _group in
            _group.post(use: addToGroup)
        }
    }

    // GET /contacts?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<ContactResponse> {
        let content = try req.query.decode(FetchAll.self)
        let pageResponse = try await repository.fetchAll(request: content,
                                                         on: req.db)
        let responseItems: [ContactResponse] = pageResponse.items.map { .init(from: $0,
                                                                              groups: []) }
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }

    // POST /contacts
    func create(req: Request) async throws -> Response {
        let content = try validator.validateCreate(req)

        let contact = try await repository.create(request: content,
                                                  on: req.db)
        let response: ContactResponse = .init(from: contact,
                                              groups: [])

        return try Response(
            status: .created,
            headers: ["Content-Type": "application/json"],
            body: .init(data: JSONEncoder().encode(response))
        )
    }

    // GET /contacts:id
    func getByID(req: Request) async throws -> ContactResponse {
        let content = try validator.validateID(req)

        let contact = try await repository.fetchById(request: content,
                                                     on: req.db)
        return .init(from: contact,
                     groups: [])
    }

    // PUT /contacts/:id
    func update(req: Request) async throws -> ContactResponse {
        let (id, content) = try validator.validateUpdate(req)
        let contact = try await repository.update(byId: id,
                                                  request: content,
                                                  on: req.db)
        return .init(from: contact,
                     groups: [])
    }

    // PUT /contacts/:id/businese_address/:address_id
    func updateBussineseAddress(req: Request) async throws -> ContactResponse {
        let content = try validator.validateUpdateBussineseAddress(req)

        let contact = try await repository.updateBussineseAddress(byId: content.id,
                                                                  addressID: content.addressID,
                                                                  request: content.content,
                                                                  on: req.db)
        return .init(from: contact,
                     groups: [])
    }

    // PUT /contacts/:id/shipping_address/:address_id
    func updateShippingAddress(req: Request) async throws -> ContactResponse {
        let content = try validator.validateUpdateShippingAddress(req)

        let contact = try await repository.updateShippingAddress(byId: content.id,
                                                                 addressID: content.addressID,
                                                                 request: content.content,
                                                                 on: req.db)
        return .init(from: contact,
                     groups: [])
    }

    // DELETE /contacts/:id
    func delete(req: Request) async throws -> ContactResponse {
        let id = try validator.validateID(req)

        let contact = try await repository.delete(byId: id,
                                                  on: req.db)
        return .init(from: contact,
                     groups: [])
    }

    // GET /contacts/search?q=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ContactResponse> {
        let content = try validator.validateSearchQuery(req)

        let pageResponse = try await repository.search(request: content, on: req.db)
        let responseItems: [ContactResponse] = pageResponse.items.map { .init(from: $0,
                                                                              groups: []) }
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }

    // POST /contacts/group
    func addToGroup(req: Request) async throws -> Response {
        let content = try validator.validateAddToGroup(req)
        let response = try await repository.addToGroup(request: content, on: req.db)

        return Response(status: .ok)
    }
}
