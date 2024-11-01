import Foundation
import Vapor
import Mockable

@Mockable
protocol MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusinessRequest.Create
    typealias UpdateContent = MyBusinessRequest.Update
    typealias UpdateBusinessAddressResponse = MyBusinessRequest.UpdateBusinessAddressResponse
    typealias UpdateShippingAddressResponse = MyBusinessRequest.UpdateShippingAddressResponse
    
    func validateCreate(_ req: Request) throws -> CreateContent
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UpdateContent)
    func validateUpdateBusineseAddress(_ req: Request) throws -> UpdateBusinessAddressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> UpdateShippingAddressResponse
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
}

class MyBusineseValidator: MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusinessRequest.Create
    typealias UpdateContent = MyBusinessRequest.Update
    typealias UpdateBusinessAddressResponse = MyBusinessRequest.UpdateBusinessAddressResponse
    typealias UpdateShippingAddressResponse = MyBusinessRequest.UpdateShippingAddressResponse
    
    func validateCreate(_ req: Request) throws -> CreateContent {
        try CreateContent.validate(content: req)
        
        return try req.content.decode(CreateContent.self)
    }
    
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UpdateContent) {
        try UpdateContent.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(UpdateContent.self)
        return (fetchById, content)
    }
    
    func validateUpdateBusineseAddress(_ req: Request) throws -> UpdateBusinessAddressResponse {
        try MyBusinessRequest.UpdateBusinessAddress.validate(content: req)
        
        let content = try req.content.decode(MyBusinessRequest.UpdateBusinessAddress.self)
        
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: .init(id: id),
                     addressID: .init(id: addressID),
                     content: content)
    }
    
    func validateUpdateShippingAddress(_ req: Request) throws -> UpdateShippingAddressResponse {
        try MyBusinessRequest.UpdateShippingAddress.validate(content: req)
        
        let content = try req.content.decode(MyBusinessRequest.UpdateShippingAddress.self)
        
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
}
