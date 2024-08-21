import Foundation
import Vapor
import Mockable

@Mockable
protocol ProductCategoryValidatorProtocol {
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> ProductCategoryRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: ProductCategoryRequest.Update)
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> Search
}

class ProductCategoryValidator: ProductCategoryValidatorProtocol {
    typealias Create = ProductCategoryRequest.Create
    typealias Update = (id: GeneralRequest.FetchById, content: ProductCategoryRequest.Update)
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> Create {
        try Create.validate(content: req)
        
        return try req.content.decode(Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> Update {
        try ProductCategoryRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(ProductCategoryRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {
        return try req.query.decode(GeneralRequest.FetchById.self)
    }
    
    func validateSearchQuery(_ req: Request) throws -> Search {
        try Search.validate(content: req)
        
        let content = try req.query.decode(Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
}
