import Foundation
import Vapor

protocol PurchaseOrderValidatorProtocol {
    typealias Create = PurchaseOrderRequest.Create
    typealias CreateItem = PurchaseOrderRequest.CreateItem
    typealias Update = (id: GeneralRequest.FetchById, content: PurchaseOrderRequest.Update)
    typealias Search = PurchaseOrderRequest.Search
    typealias Fetch = PurchaseOrderRequest.FetchAll
    
    func validateCreate(_ req: Request) throws -> Create
    func validateUpdate(_ req: Request) throws -> Update
    func validateSearchQuery(_ req: Request) throws -> Search
    func validateFetchQuery(_ req: Request) throws -> Fetch
}

class PurchaseOrderValidator: PurchaseOrderValidatorProtocol {
  
    typealias Create = PurchaseOrderRequest.Create
    typealias CreateItem = PurchaseOrderRequest.CreateItem
    typealias Update = (id: GeneralRequest.FetchById, content: PurchaseOrderRequest.Update)
    typealias Search = PurchaseOrderRequest.Search
    typealias Fetch = PurchaseOrderRequest.FetchAll
    
    func validateCreate(_ req: Request) throws -> Create {
        try Create.validate(content: req)
        
        return try req.content.decode(Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> Update {
        try ServiceRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(PurchaseOrderRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateSearchQuery(_ req: Request) throws -> Search {
        try Search.validate(content: req)
        
        let content = try req.query.decode(Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
    
    func validateFetchQuery(_ req: Request) throws -> Fetch {
        try Fetch.validate(content: req)
        
        let content = try req.query.decode(Fetch.self)
        
        return content
    }
    
}
