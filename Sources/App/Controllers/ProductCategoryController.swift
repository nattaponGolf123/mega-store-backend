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
        
        cates.group("search") { _search in
            _search.get(use: search)
        }
    }
    
    // GET /product_categories?show_deleted=true
    func all(req: Request) async throws -> [ProductCategory] {
        let showDeleted = req.query["show_deleted"] == "true"
        
        //fetch all inclued deleted
        if showDeleted {
            
            do {
                return try await ProductCategory.query(on: req.db).withDeleted().all()
            } catch {
                throw DefaultError.dbConnectionError
            }
                        
        } else {
            do {
                return try await ProductCategory.query(on: req.db).filter(\.$deletedAt == nil).all()
            } catch {
                throw DefaultError.dbConnectionError
            }
        }
    }
    
    // POST /product_categories
    func create(req: Request) async throws -> ProductCategory {
        do {
            // Decode the incoming content
            let content = try req.content.decode(CreateProductCategory.self)

            // Validate the content directly
            try CreateProductCategory.validate(content: req)

            // Initialize the ProductCategory from the validated content
            let newCate = ProductCategory(name: content.name)

            // Attempt to save the new category to the database
            try await newCate.save(on: req.db)

            // Return the newly created category
            return newCate
        } catch let error as ValidationsError {
            // Parse and throw a more specific input validation error if validation fails
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch let error as DecodingError {
            // Handle JSON decoding errors
            print(error)
            throw DefaultError.invalidInput
        } catch let error as FluentError {
            // Handle Fluent specific errors, e.g., model not found
            print(error)
            throw DefaultError.dbConnectionError
        } catch {
            // Handle all other errors
            throw DefaultError.serverError
        }
    }    
    
    // GET /product_categories/:id
    func getByID(req: Request) async throws -> ProductCategory {
        guard
            let id = req.parameters.get("id",
                                        as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        guard
            let category = try await ProductCategory.query(on: req.db).filter(\.$id == id).first()
        else { throw DefaultError.notFound }
        
        return category
    }
    
    // PUT /product_categories/:id
    func update(req: Request) async throws -> ProductCategory {
     
        do {
            // Decode the incoming content and validate it
            let content = try req.content.decode(UpdateProductCategory.self)
            try UpdateProductCategory.validate(content: req)
            
            // Extract the ID from the request's parameters
            guard let id = req.parameters.get("id", as: UUID.self) else {
                throw DefaultError.invalidInput
            }

            // Update the product category in the database
            let updateBuilder = updateFieldsBuilder(uuid: id, content: content, db: req.db)
            try await updateBuilder.update()

            // Retrieve the updated product category
            guard let category = try await getByIDBuilder(uuid: id, db: req.db).first() else {
                throw DefaultError.notFound
            }

            return category
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch let error as FluentError {
            print(error)
            throw DefaultError.dbConnectionError
        } catch {
            throw DefaultError.serverError
        }
    }
    
    // DELETE /product_categories/:id
    func delete(req: Request) async throws -> ProductCategory {
        guard
            let id = req.parameters.get("id"),
            let uuid = UUID(id)
        else { throw DefaultError.invalidInput }
        
        guard
            let cate = try await ProductCategory.query(on: req.db).filter(\.$id == uuid).first()
        else { throw DefaultError.notFound }
        
        do {
            try await cate.delete(on: req.db).get()
        } catch {
            throw DefaultError.dbConnectionError
        }
        
        return cate
    }
    
    // GET /product_categories/search
    func search(req: Request) async throws -> [ProductCategory] {
        guard
            let search = req.query[String.self,
                                   at: "q"]
        else { throw DefaultError.invalidInput }
        
        do {
            return try await ProductCategory.query(on: req.db).filter(\.$name ~~ search).all()
        } catch {
            throw DefaultError.dbConnectionError
        }
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
                            is: .count(3...400))
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



