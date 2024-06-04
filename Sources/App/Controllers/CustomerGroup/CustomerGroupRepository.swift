import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol CustomerGroupRepositoryProtocol {
    func fetchAll(showDeleted: Bool, on db: Database) async throws -> [CustomerGroup]
    func create(content: CustomerGroup.Create, on db: Database) async throws -> CustomerGroup
    func find(id: UUID, on db: Database) async throws -> CustomerGroup
    func find(name: String, on db: Database) async throws -> CustomerGroup
    func update(id: UUID, with content: CustomerGroup.Update, on db: Database) async throws -> CustomerGroup
    func delete(id: UUID, on db: Database) async throws -> CustomerGroup
    func search(name: String, on db: Database) async throws -> [CustomerGroup]
}

class CustomerGroupRepository: CustomerGroupRepositoryProtocol {
     
    func fetchAll(showDeleted: Bool, on db: Database) async throws -> [CustomerGroup] {
        do {
            if showDeleted {
                return try await CustomerGroup.query(on: db).withDeleted().all()
            } else {
                return try await CustomerGroup.query(on: db).filter(\.$deletedAt == nil).all()
            }
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func create(content: CustomerGroup.Create, on db: Database) async throws -> CustomerGroup {
        do {
            // Initialize the CustomerGroup from the validated content
            let newGroup = CustomerGroup(name: content.name, description: content.description)
    
            // Attempt to save the new group to the database
            try await newGroup.save(on: db)
            
            // Return the newly created group
            return newGroup
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func find(id: UUID, on db: Database) async throws -> CustomerGroup {
        do {
            guard let group = try await CustomerGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return group
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> CustomerGroup {
        do {
            guard let group = try await CustomerGroup.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func update(id: UUID, with content: CustomerGroup.Update, on db: Database) async throws -> CustomerGroup {
        do {
            
            // Update the supplier group in the database
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            // Retrieve the updated supplier group
            guard let group = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func delete(id: UUID, on db: Database) async throws -> CustomerGroup {
        do {
            guard let group = try await CustomerGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await group.delete(on: db).get()
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func search(name: String, on db: Database) async throws -> [CustomerGroup] {
        do {
            return try await CustomerGroup.query(on: db).filter(\.$name ~~ name).all()
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
}

extension CustomerGroupRepository {
    
    // Helper function to update supplier group fields in the database
    static func updateFieldsBuilder(uuid: UUID, content: CustomerGroup.Update, db: Database) -> QueryBuilder<CustomerGroup> {
        let updateBuilder = CustomerGroup.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<CustomerGroup> {
        return CustomerGroup.query(on: db).filter(\.$id == uuid)
    }
}