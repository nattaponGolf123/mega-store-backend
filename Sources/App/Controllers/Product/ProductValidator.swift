import Foundation
import Vapor
import Mockable

@Mockable
protocol ProductValidatorProtocol {
    typealias Create = ProductRequest.Create
    typealias Update = (id: GeneralRequest.FetchById, content: ProductRequest.Update)
    
    typealias CreateVariant = (id: GeneralRequest.FetchById, content: ProductRequest.CreateVariant)
    typealias UpdateVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById, content: ProductRequest.UpdateVariant)
    typealias DeleteVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById)
        
    func validateCreate(_ req: Request) throws -> Create
    func validateUpdate(_ req: Request) throws -> Update

    func validateCreateVariant(_ req: Request) throws -> CreateVariant
    func validateUpdateVariant(_ req: Request) throws -> UpdateVariant
    func validateDeleteVariant(_ req: Request) throws -> DeleteVariant
}

class ProductValidator: ProductValidatorProtocol {
    typealias Create = ProductRequest.Create
    typealias Update = (id: GeneralRequest.FetchById, content: ProductRequest.Update)
    typealias Search = GeneralRequest.Search
    
    typealias CreateVariant = (id: GeneralRequest.FetchById, content: ProductRequest.CreateVariant)
    typealias UpdateVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById, content: ProductRequest.UpdateVariant)
    typealias DeleteVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById)
    
    func validateCreate(_ req: Request) throws -> Create {
        try Create.validate(content: req)
        
        return try req.content.decode(Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> Update {
        try ProductRequest.Update.validate(content: req)
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(ProductRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateCreateVariant(_ req: Request) throws -> CreateVariant {
        try ProductRequest.CreateVariant.validate(content: req)
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(ProductRequest.CreateVariant.self)
        
        return (fetchById, content)
    }
    
    func validateUpdateVariant(_ req: Request) throws -> UpdateVariant {
        try ProductRequest.UpdateVariant.validate(content: req)
        
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let variantId = req.parameters.get("variant_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        let fetchById = GeneralRequest.FetchById(id: id)
        let variantFetchById = GeneralRequest.FetchById(id: variantId)
        let content = try req.content.decode(ProductRequest.UpdateVariant.self)
        
        return (fetchById, variantFetchById, content)
    }
    
    func validateDeleteVariant(_ req: Request) throws -> DeleteVariant {
        guard
            let id = req.parameters.get("id", as: UUID.self),
            let variantId = req.parameters.get("variant_id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        let fetchById = GeneralRequest.FetchById(id: id)
        let variantFetchById = GeneralRequest.FetchById(id: variantId)
        
        return (fetchById, variantFetchById)
    }
    
}
