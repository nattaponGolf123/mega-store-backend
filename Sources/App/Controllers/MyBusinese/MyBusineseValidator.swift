import Foundation
import Vapor
import Mockable

@Mockable
protocol MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusineseRequest.Create
    typealias UpdateContent = MyBusineseRequest.Update
    typealias UpdateBusineseAdressResponse = MyBusineseRequest.UpdateBusineseAdressResponse
    typealias UpdateShippingAddressResponse = MyBusineseRequest.UpdateShippingAddressResponse
    
    func validateCreate(_ req: Request) throws -> CreateContent
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UpdateContent)
    func validateUpdateBussineseAddress(_ req: Request) throws -> UpdateBusineseAdressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> UpdateShippingAddressResponse
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
}

class MyBusineseValidator: MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusineseRequest.Create
    typealias UpdateContent = MyBusineseRequest.Update
    typealias UpdateBusineseAdressResponse = MyBusineseRequest.UpdateBusineseAdressResponse
    typealias UpdateShippingAddressResponse = MyBusineseRequest.UpdateShippingAddressResponse
    
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
    
    func validateUpdateBussineseAddress(_ req: Request) throws -> UpdateBusineseAdressResponse {
        try MyBusineseRequest.UpdateBussineseAddress.validate(content: req)
        
        let content = try req.content.decode(MyBusineseRequest.UpdateBussineseAddress.self)
        
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: .init(id: id),
                     addressID: .init(id: addressID),
                     content: content)
    }
    
    func validateUpdateShippingAddress(_ req: Request) throws -> UpdateShippingAddressResponse {
        try MyBusineseRequest.UpdateShippingAddress.validate(content: req)
        
        let content = try req.content.decode(MyBusineseRequest.UpdateShippingAddress.self)
        
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
