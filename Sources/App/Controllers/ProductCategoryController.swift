//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class ProductCategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let cates = routes.grouped("product_categories")
        cates.get(use: all)
        cates.post(use: create)
        
        cates.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            withID.delete(use: delete)
        }
        
        cates.group("all") { all in
            all.get(use: getAll)
        }
    }
    
    // GET /product_categories
    func all(req: Request) async throws -> [ProductCategory] {
        return try await ProductCategory.query(on: req.db).all()
    }
    
    // POST /product_categories
    func create(req: Request) async throws -> ProductCategory {
        // try to decode param by CreateContent
        let content = try req.content.decode(CreateProductCategory.self)
        
        // validate
        try CreateProductCategory.validate(content: req)
        
        let newCate = ProductCategory(name: content.name)
        try await newCate.save(on: req.db).get()
        
        return newCate
    }
    
    // GET /product_categories/:id
    func getByID(req: Request) async throws -> ProductCategory {
        guard
            let id = req.parameters.get("id",
                                        as: UUID.self)
        else { throw Abort(.badRequest) }
        
        guard
            let cate = try await ProductCategory.query(on: req.db).filter(\.$id == id).first()
        else { throw Abort(.notFound) }
        
        return cate
    }
    
    // PUT /product_categories/:id
    func update(req: Request) async throws -> ProductCategory {
        // try to decode param by CreateContent
        let content = try req.content.decode(UpdateProductCategory.self)
        
        // validate
        try CreateProductCategory.validate(content: req)
        
        guard
            let id = req.parameters.get("id",
                                        as: UUID.self)
        else { throw Abort(.badRequest) }
        
        let updateBuilder = updateFieldsBuilder(uuid: id,
                                                content: content,
                                                db: req.db)
        try await updateBuilder.update()
        
        do {
            guard
                let cate = try await getByIDBuilder(uuid: id,
                                                       db: req.db).first()
            else { throw Abort(.notFound) }
            
            return cate
        } catch {
            throw Abort(.notFound)
        }
    }
    
    // DELETE /product_categories/:id
    func delete(req: Request) async throws -> HTTPStatus {
        guard
            let id = req.parameters.get("id"),
            let uuid = UUID(id)
        else { throw Abort(.badRequest) }
        
        try await ProductCategory.query(on: req.db).filter(\.$id == uuid).delete()
                
        return .ok
    }
    
    // GET /product_categories/all
    func getAll(req: Request) async throws -> [ProductCategory] {
        return try await ProductCategory.query(on: req.db).all()
    }
    
}

private extension ProductCategoryController {
    
    // Helper function to update product fields in the database
    func updateFieldsBuilder(uuid: UUID,
                             content: UpdateProductCategory,
                             db: Database) -> QueryBuilder<ProductCategory> {
        let updateBuilder = ProductCategory.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name,
                               to: name)
        }
        
        return updateBuilder
    }
    
    func getByIDBuilder(uuid: UUID,
                        db: Database) -> QueryBuilder<ProductCategory> {
        return ProductCategory.query(on: db).filter(\.$id == uuid)
    }
}

extension ProductCategoryController {
    
    struct QueryProductCategory: Content {
        let name: String?
    }
    
    struct RequestParameter: Content {
        let id: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let _id = try container.decode(String.self,
                                           forKey: .id)
            guard
                let id = Int(_id)
            else { throw Abort(.badRequest) }
            
            self.id = id
        }
    }
    
    struct CreateProductCategory: Content, Validatable {
        let name: String
        
        init(name: String) {
            self.name = name
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(1...))
        }
    }
    
    struct UpdateProductCategory: Content, Validatable {
        let name: String?
        
        init(name: String? = nil) {
            self.name = name
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(1...))
        }
    }
    
}



