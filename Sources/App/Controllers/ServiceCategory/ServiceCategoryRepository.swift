//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ServiceCategoryRepositoryProtocol {
    func fetchAll(showDeleted: Bool,
                  on db: Database) async throws -> [ServiceCategory]
    func create(content: ServiceCategoryController.CreateContent,
                on db: Database) async throws -> ServiceCategory
    func find(id: UUID,
              on db: Database) async throws -> ServiceCategory
    func find(name: String,
              on db: Database) async throws -> ServiceCategory
    func update(id: UUID,
                with content: ServiceCategoryController.UpdateContent,
                on db: Database) async throws -> ServiceCategory
    func delete(id: UUID, on db: Database) async throws -> ServiceCategory
    func search(name: String, on db: Database) async throws -> [ServiceCategory]
}

class FluentServiceCategoryRepository: ServiceCategoryRepositoryProtocol {
     
    func fetchAll(showDeleted: Bool,
                  on db: Database) async throws -> [ServiceCategory] {
        do {
            if showDeleted {
                return try await ServiceCategory.query(on: db).withDeleted().all()
            } else {
                return try await ServiceCategory.query(on: db).filter(\.$deletedAt == nil).all()
            }
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func create(content: ServiceCategoryController.CreateContent,
                on db: Database) async throws -> ServiceCategory {
        do {
            // Initialize the ServiceCategory from the validated content
            let newCate = ServiceCategory(name: content.name)
    
            // Attempt to save the new category to the database
            try await newCate.save(on: db)
            
            // Return the newly created category
            return newCate
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func find(id: UUID,
              on db: Database) async throws -> ServiceCategory {
        do {
            guard
                let category = try await ServiceCategory.query(on: db).filter(\.$id == id).first()
            else { throw DefaultError.notFound }
            
            return category
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func find(name: String,
              on db: Database) async throws -> ServiceCategory {
        do {
            guard
                let category = try await ServiceCategory.query(on: db).filter(\.$name == name).first()
            else { throw DefaultError.notFound }
            
            return category
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID,
                with content: ServiceCategoryController.UpdateContent,
                on db: Database) async throws -> ServiceCategory {
        do {
            // Update the product category in the database
            let updateBuilder = Self.updateFieldsBuilder(uuid: id,
                                                         content: content,
                                                         db: db)
            try await updateBuilder.update()
            
            // Retrieve the updated product category
            guard
                let category = try await Self.getByIDBuilder(uuid: id,
                                                             db: db).first()
            else { throw DefaultError.notFound }
            
            return category
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func delete(id: UUID,
                on db: Database) async throws -> ServiceCategory {
        do {
            guard
                let category = try await ServiceCategory.query(on: db).filter(\.$id == id).first()
            else { throw DefaultError.notFound }
            
            try await category.delete(on: db).get()
            
            return category
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func search(name: String,
                on db: Database) async throws -> [ServiceCategory] {
        do {
            return try await ServiceCategory.query(on: db).filter(\.$name ~~ name).all()
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
}

extension FluentServiceCategoryRepository {
    
    // Helper function to update product fields in the database
    static func updateFieldsBuilder(uuid: UUID,
                             content: ServiceCategoryController.UpdateContent,
                             db: Database) -> QueryBuilder<ServiceCategory> {
        let updateBuilder = ServiceCategory.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name,
                               to: name)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID,
                        db: Database) -> QueryBuilder<ServiceCategory> {
        return ServiceCategory.query(on: db).filter(\.$id == uuid)
    }
}
