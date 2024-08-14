import Foundation
import Vapor

protocol MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusineseRequest.Create
    typealias UpdateContent = MyBusineseRequest.Update
    
    func validateCreate(_ req: Request) throws -> CreateContent
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UpdateContent)
    func validateUpdateBussineseAddress(_ req: Request) throws -> MyBusineseValidator.ValidateBusineseAdressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> MyBusineseValidator.ValidateShippingAddressResponse
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
}

class MyBusineseValidator: MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusineseRequest.Create
    typealias UpdateContent = MyBusineseRequest.Update
    
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

    func validateUpdateBussineseAddress(_ req: Request) throws -> ValidateBusineseAdressResponse {
        do {
            try MyBusineseRequest.UpdateBussineseAddress.validate(content: req)
            
            let content = try req.content.decode(MyBusineseRequest.UpdateBussineseAddress.self)
            
            guard
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
                else { throw DefaultError.invalidInput }

            return .init(id: .init(id: id),
                         addressID: .init(id: addressID),
                        content: content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateShippingAddress(_ req: Request) throws -> ValidateShippingAddressResponse {
        do {
            try MyBusineseRequest.UpdateShippingAddress.validate(content: req)
            
            let content = try req.content.decode(MyBusineseRequest.UpdateShippingAddress.self)
            
            guard 
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
             else { throw DefaultError.invalidInput }

            return .init(id: .init(id: id),
                         addressID: .init(id: addressID),
                         content: content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {
        do {
            return try req.query.decode(GeneralRequest.FetchById.self)
        } catch {
            throw DefaultError.invalidInput
        }
    }
}

extension MyBusineseValidator {
    
    struct ValidateBusineseAdressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: MyBusineseRequest.UpdateBussineseAddress
    }

    struct ValidateShippingAddressResponse {
        let id: GeneralRequest.FetchById
        let addressID: GeneralRequest.FetchById
        let content: MyBusineseRequest.UpdateShippingAddress
    }
}
