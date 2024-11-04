import Fluent
import Foundation
import Vapor

class ContactController: RouteCollection {
    typealias ContactWithGroups = (contact: Contact, groups: [ContactGroup])

    private(set) var repository: ContactRepositoryProtocol
    private(set) var groupRepository: ContactGroupRepositoryProtocol
    private(set) var validator: ContactValidatorProtocol

    init(
        repository: ContactRepositoryProtocol = ContactRepository(),
        groupRepository: ContactGroupRepositoryProtocol = ContactGroupRepository(),
        validator: ContactValidatorProtocol = ContactValidator()
    ) {
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
                bussineseAddress.grouped(":address_id").put(use: updateBusinessAddress)
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
        let content = try req.query.decode(ContactRequest.FetchAll.self)
        let pageResponse = try await repository.fetchAll(
            request: content,
            on: req.db)

        let contactWithGroups: [ContactWithGroups] = try await fetchContactsWithGroups(from: pageResponse.items, on: req.db)
        
        let contactResponses: [ContactResponse] = contactWithGroups.map({
            .init(from: $0,
                  groups: $1)
        })
        
        return .init(
            page: pageResponse.page,
            perPage: pageResponse.perPage,
            total: pageResponse.total,
            items: contactResponses)
    }

    // POST /contacts
    func create(req: Request) async throws -> Response {
        let content = try validator.validateCreate(req)

        let contact = try await repository.create(
            request: content,
            on: req.db)
       
        let contactWithGroups: ContactWithGroups = try await fetchContactsWithGroups(from: [contact], on: req.db).first!

        let response: ContactResponse = .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)            

        return try Response(
            status: .created,
            headers: ["Content-Type": "application/json"],
            body: .init(data: JSONEncoder().encode(response))
        )
    }

    // GET /contacts:id
    func getByID(req: Request) async throws -> ContactResponse {
        let content = try validator.validateID(req)

        let contact = try await repository.fetchById(
            request: content,
            on: req.db)

        let contactWithGroups: ContactWithGroups = try await fetchSingleContactGroups(from: contact, on: req.db)

        return .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)
    }

    // PUT /contacts/:id
    func update(req: Request) async throws -> ContactResponse {
        let (id, content) = try validator.validateUpdate(req)
        let contact = try await repository.update(
            byId: id,
            request: content,
            on: req.db)
       
        let contactWithGroups: ContactWithGroups = try await fetchSingleContactGroups(from: contact, on: req.db)

        return .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)
    }

    // PUT /contacts/:id/businese_address/:address_id
    func updateBusinessAddress(req: Request) async throws -> ContactResponse {
        let content = try validator.validateUpdateBusineseAddress(req)

        let contact = try await repository.updateBusinessAddress(
            byId: content.id,
            addressID: content.addressID,
            request: content.content,
            on: req.db)
       
        let contactWithGroups: ContactWithGroups = try await fetchSingleContactGroups(from: contact, on: req.db)

        return .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)
    }

    // PUT /contacts/:id/shipping_address/:address_id
    func updateShippingAddress(req: Request) async throws -> ContactResponse {
        let content = try validator.validateUpdateShippingAddress(req)

        let contact = try await repository.updateShippingAddress(
            byId: content.id,
            addressID: content.addressID,
            request: content.content,
            on: req.db)
       
        let contactWithGroups: ContactWithGroups = try await fetchSingleContactGroups(from: contact, on: req.db)

        return .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)
    }

    // DELETE /contacts/:id
    func delete(req: Request) async throws -> ContactResponse {
        let id = try validator.validateID(req)

        let contact = try await repository.delete(
            byId: id,
            on: req.db)
       
        let contactWithGroups: ContactWithGroups = try await fetchSingleContactGroups(from: contact, on: req.db)
        return .init(
            from: contactWithGroups.contact,
            groups: contactWithGroups.groups)
    }

    // GET /contacts/search?q=xxx&page=1&per_page=10
    func search(req: Request) async throws -> PaginatedResponse<ContactResponse> {
        let content = try validator.validateSearchQuery(req)

        let pageResponse = try await repository.search(request: content, on: req.db)

        let contactWithGroups: [ContactWithGroups] = try await fetchContactsWithGroups(from: pageResponse.items, on: req.db)

        let contactResponses: [ContactResponse] = contactWithGroups.map({
            .init(from: $0,
                  groups: $1)
        })

        return .init(
            page: pageResponse.page,
            perPage: pageResponse.perPage,
            total: pageResponse.total,
            items: contactResponses)
    }

    // POST /contacts/group
    func addToGroup(req: Request) async throws -> Response {
        let content = try validator.validateAddToGroup(req)
        _ = try await repository.addToGroup(request: content, on: req.db)

        return Response(status: .created)
    }
}

private
extension ContactController {
    func fetchContactsWithGroups(from contacts: [Contact],
                               on db: Database) async throws
        -> [ContactWithGroups]
    {
        try await withThrowingTaskGroup(of: ContactWithGroups.self) { group in
            for contact in contacts {
                group.addTask {
                    try await self.fetchSingleContactGroups(from: contact, on: db)
                }
            }

            var responses: [ContactWithGroups] = []
            for try await response in group {
                responses.append(response)
            }
            return responses
        }
    }
    
    // return single of Contact
    func fetchSingleContactGroups(from contact: Contact,
                                    on db: Database) async throws
            -> ContactWithGroups
    {
        var groups: [ContactGroup] = try await groupRepository.fetchByIds(
            request: .init(ids: contact.groupIds),
            on: db)
        
        return (contact: contact, groups: groups)
    }
}
