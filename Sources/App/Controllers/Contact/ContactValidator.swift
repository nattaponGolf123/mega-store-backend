import Foundation
import Vapor
import Mockable

@Mockable
protocol ContactValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: ContactRequest.Update)
    func validateUpdateBusineseAddress(_ req: Request) throws -> ContactRequest.UpdateBusinessAddressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> ContactRequest.UpdateShippingAddressResponse
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> ContactRequest.Search
    func validateAddToGroup(_ req: Request) throws -> ContactRequest.AddToGroup
}

class ContactValidator: ContactValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactRequest.Create {
        try ContactRequest.Create.validate(content: req)
        
        return try req.content.decode(ContactRequest.Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: ContactRequest.Update) {
        try ContactRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(ContactRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateUpdateBusineseAddress(_ req: Request) throws -> ContactRequest.UpdateBusinessAddressResponse {
        try ContactRequest.UpdateBusinessAddress.validate(content: req)
        
        let content = try req.content.decode(ContactRequest.UpdateBusinessAddress.self)
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: .init(id: id),
                     addressID: .init(id: addressID),
                     content: content)
    }
    
    func validateUpdateShippingAddress(_ req: Request) throws -> ContactRequest.UpdateShippingAddressResponse {
        try ContactRequest.UpdateShippingAddress.validate(content: req)
        
        let content = try req.content.decode(ContactRequest.UpdateShippingAddress.self)
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: .init(id: id),
                     addressID: .init(id: addressID),
                     content: content)
    }
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {        
        guard
            let id = req.parameters.get("id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: id)
    }
    
    func validateSearchQuery(_ req: Request) throws -> ContactRequest.Search {
        //try ContactRequest.Search.validate(content: req)
        
        let content = try req.query.decode(ContactRequest.Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
    
    func validateAddToGroup(_ req: Request) throws -> ContactRequest.AddToGroup {
        try ContactRequest.AddToGroup.validate(content: req)
        
        let content = try req.content.decode(ContactRequest.AddToGroup.self)
        
        guard !content.contactIds.isEmpty else {
            throw DefaultError.invalidInput
        }
        
        return content
    }
}
