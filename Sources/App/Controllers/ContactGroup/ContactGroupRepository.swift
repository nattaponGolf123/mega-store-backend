import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ContactGroupRepositoryProtocol {
    func fetchAll(showDeleted: Bool, on db: Database) async throws -> [ContactGroup]
    func create(content: ContactGroupRepository.Create, on db: Database) async throws -> ContactGroup
    func find(id: UUID, on db: Database) async throws -> ContactGroup
    func find(name: String, on db: Database) async throws -> ContactGroup
    func update(id: UUID, with content: ContactGroupRepository.Update, on db: Database) async throws -> ContactGroup
    func delete(id: UUID, on db: Database) async throws -> ContactGroup
    func search(name: String, on db: Database) async throws -> [ContactGroup]
}

class ContactGroupRepository: ContactGroupRepositoryProtocol {
     
    func fetchAll(showDeleted: Bool, on db: Database) async throws -> [ContactGroup] {
        do {
            if showDeleted {
                return try await ContactGroup.query(on: db).withDeleted().all()
            } else {
                return try await ContactGroup.query(on: db).filter(\.$deletedAt == nil).all()
            }
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func create(content: ContactGroupRepository.Create, on db: Database) async throws -> ContactGroup {
        do {
            // Initialize the ContactGroup from the validated content
            let newGroup = ContactGroup(name: content.name, description: content.description)
    
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

    func find(id: UUID, on db: Database) async throws -> ContactGroup {
        do {
            guard let group = try await ContactGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return group
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ContactGroup {
        do {
            guard let group = try await ContactGroup.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func update(id: UUID, with content: ContactGroupRepository.Update, on db: Database) async throws -> ContactGroup {
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

    func delete(id: UUID, on db: Database) async throws -> ContactGroup {
        do {
            guard let group = try await ContactGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await group.delete(on: db).get()
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func search(name: String, on db: Database) async throws -> [ContactGroup] {
        do {
        let regexPattern = "(?i)\(name)"  // (?i) makes the regex case-insensitive
        return try await ContactGroup.query(on: db)
            .filter(\.$name =~ regexPattern)
            .all()
        } catch {
         // Handle all other errors
         throw DefaultError.error(message: error.localizedDescription)
      }
    }
}

extension ContactGroupRepository {
    
    // Helper function to update supplier group fields in the database
    static func updateFieldsBuilder(uuid: UUID, content: ContactGroupRepository.Update, db: Database) -> QueryBuilder<ContactGroup> {
        let updateBuilder = ContactGroup.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<ContactGroup> {
        return ContactGroup.query(on: db).filter(\.$id == uuid)
    }
}

extension ContactGroupRepository { 
    struct Create: Content, Validatable {
        let name: String
        let description: String?
        
        init(name: String,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                    forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
                
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        
        init(name: String? = nil,
            description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
}