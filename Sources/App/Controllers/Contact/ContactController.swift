import Foundation
import Fluent
import Vapor

class ContactController: RouteCollection {
    
    private(set) var repository: ContactRepositoryProtocol
    private(set) var validator: ContactValidatorProtocol
    
    init(repository: ContactRepositoryProtocol = ContactRepository(),
         validator: ContactValidatorProtocol = ContactValidator()) {
        self.repository = repository
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
            
            //PUT /contacts/:id/shipping_address/:address_id
            withID.group("shipping_address") { shippingAddress in
                shippingAddress.grouped(":address_id").put(use: updateShippingAddress)
            }
            
            //DELETE /contacts/:id
            withID.delete(use: delete)
        }

         contacts.group("search") { _search in
            _search.get(use: search)
        }
        
    }
    
    // GET /contacts?show_deleted=true&page=1&per_page=10
    func all(req: Request) async throws -> PaginatedResponse<Contact> {
        let reqContent = try req.query.decode(ContactRepository.Fetch.self)
        return try await repository.fetchAll(req: reqContent, on: req.db)
    }

    // POST /contacts
   func create(req: Request) async throws -> Contact {
       let content = try validator.validateCreate(req)
       return try await repository.create(with: content, on: req.db)
   }

     // GET /contacts:id
    func getByID(req: Request) async throws -> Contact {
        let uuid = try validator.validateID(req)
        return try await repository.find(id: uuid, on: req.db)
    }
    
    // PUT /contacts/:id
    func update(req: Request) async throws -> Contact {
        let (uuid, content) = try validator.validateUpdate(req)
        return try await repository.update(id: uuid, with: content, on: req.db)
    }
    
    // PUT /contacts/:id/businese_address/:address_id
    func updateBussineseAddress(req: Request) async throws -> Contact {
        let result = try validator.validateUpdateBussineseAddress(req)
        return try await repository.updateBussineseAddress(id: result.id,
                                                           addressID: result.addressID,
                                                           with: result.content,
                                                           on: req.db)
    }
    
    // PUT /contacts/:id/shipping_address/:address_id
    func updateShippingAddress(req: Request) async throws -> Contact {
        let result = try validator.validateUpdateShippingAddress(req)
        return try await repository.updateShippingAddress(id: result.id,
                                                          addressID: result.addressID,
                                                          with: result.content,
                                                          on: req.db)
    }
    
   func delete(req: Request) async throws -> Contact {
       let uuid = try validator.validateID(req)
       return try await repository.delete(id: uuid, on: req.db)
   }

   // GET /contacts/search?q=xxx&page=1&per_page=10
     func search(req: Request) async throws -> PaginatedResponse<Contact> {
        let _ = try validator.validateSearchQuery(req)
        let reqContent = try req.query.decode(ContactRepository.Search.self)
        
        return try await repository.search(req: reqContent, on: req.db)        
    }
}

/*
 protocol ContactRepositoryProtocol {
 func fetchAll(on db: Database) async throws -> [Contact]
 //func create(with content: ContactRepository.Create, on db: Database) async throws -> Contact
 func find(id: UUID, on db: Database) async throws -> Contact
 func update(id: UUID, with content: ContactRepository.Update, on db: Database) async throws -> Contact
 //func delete(id: UUID, on db: Database) async throws -> Contact
 func updateBussineseAddress(id: UUID, with content: ContactRepository.UpdateBussineseAddress, on db: Database) async throws -> Contact
 func updateShippingAddress(id: UUID, with content: ContactRepository.UpdateShippingAddress, on db: Database) async throws -> Contact
 }
 */

/*
 class ContactValidator: ContactValidatorProtocol {
 typealias CreateContent = ContactRepository.Create
 typealias UpdateContent = ContactRepository.Update
 
 func validateCreate(_ req: Request) throws -> CreateContent {
 
 do {
 let content = try req.content.decode(CreateContent.self)
 try CreateContent.validate(content: req)
 return content
 } catch let error as ValidationsError {
 let errors = InputError.parse(failures: error.failures)
 throw InputValidateError.inputValidateFailed(errors: errors)
 } catch {
 throw DefaultError.invalidInput
 }
 }
 
 func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: UpdateContent) {
 
 do {
 let content = try req.content.decode(UpdateContent.self)
 try UpdateContent.validate(content: req)
 guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
 return (id, content)
 } catch let error as ValidationsError {
 let errors = InputError.parse(failures: error.failures)
 throw InputValidateError.inputValidateFailed(errors: errors)
 } catch {
 throw DefaultError.invalidInput
 }
 }
 
 func validateUpdateBussineseAddress(_ req: Request) throws -> (uuid: UUID, addressID: UUID, content: ContactRepository.UpdateBussineseAddress) {
 
 do {
 let content = try req.content.decode(ContactRepository.UpdateBussineseAddress.self)
 try ContactRepository.UpdateBussineseAddress.validate(content: req)
 guard
 let id = req.parameters.get("id", as: UUID.self),
 let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
 else { throw DefaultError.invalidInput }
 
 return (id, addressID, content)
 } catch let error as ValidationsError {
 let errors = InputError.parse(failures: error.failures)
 throw InputValidateError.inputValidateFailed(errors: errors)
 } catch {
 throw DefaultError.invalidInput
 }
 }
 
 func validateUpdateShippingAddress(_ req: Request) throws -> (uuid: UUID, addressID: UUID, content: ContactRepository.UpdateShippingAddress) {
 
 do {
 let content = try req.content.decode(ContactRepository.UpdateShippingAddress.self)
 try ContactRepository.UpdateShippingAddress.validate(content: req)
 guard
 let id = req.parameters.get("id", as: UUID.self),
 let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
 else { throw DefaultError.invalidInput }
 
 return (id, addressID, content)
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
 }
 */
