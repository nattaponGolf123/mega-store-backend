import Foundation
import Vapor
import Mockable

@Mockable
protocol ContactGroupValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactGroupRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)
    func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search
}

class ContactGroupValidator: ContactGroupValidatorProtocol {
    typealias CreateContent = ContactGroupRequest.Create
    typealias UpdateContent = (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)
    typealias SearchContent = ContactGroupRequest.Search

    func validateCreate(_ req: Request) throws -> CreateContent {
        try CreateContent.validate(content: req)
        
        return try req.content.decode(CreateContent.self)
    }

    func validateUpdate(_ req: Request) throws -> UpdateContent {
        do {
            try ContactGroupRequest.Update.validate(content: req)
            
            let id = try req.parameters.require("id", as: UUID.self)
            let fetchById = ContactGroupRequest.FetchById(id: id)
            let content = try req.content.decode(ContactGroupRequest.Update.self)
            return (fetchById, content)
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById {
        do {
            return try req.query.decode(ContactGroupRequest.FetchById.self)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search {
        do {
            try SearchContent.validate(content: req)
            
            let content = try req.query.decode(ContactGroupRequest.Search.self)
            
            guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
            
            return content
        }
        catch {
            throw DefaultError.invalidInput
        }
    }
}
