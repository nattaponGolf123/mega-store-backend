import Foundation
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
//
//@Mockable
//protocol ContactGroupRepositoryProtocol {
//    func fetchAll(req: ContactGroupRequest.FetchAll,
//                  on db: Database) async throws -> PaginatedResponse<ContactGroup>
//    func create(content: ContactGroupRequest.Create, on db: Database) async throws -> ContactGroup
//    func find(id: UUID, on db: Database) async throws -> ContactGroup
//    func find(name: String, on db: Database) async throws -> ContactGroup
//    func update(id: UUID, with content: ContactGroupRequest.Update, on db: Database) async throws -> ContactGroup
//    func delete(id: UUID, on db: Database) async throws -> ContactGroup
//    func search(req: ContactGroupRequest.Search, on db: Database) async throws -> PaginatedResponse<ContactGroup>
//}
//
//class ContactGroupRepository: ContactGroupRepositoryProtocol {
//    
//    let ContactGroupRepository: ContactGroupRepositoryProtocol
//    
//    init(ContactGroupRepository: ContactGroupRepositoryProtocol = ContactGroupRepository()) {
//        self.ContactGroupRepository = ContactGroupRepository
//    }
//    
//    func fetchAll(req: ContactGroupRequest.FetchAll,
//                  on db: Database) async throws -> PaginatedResponse<ContactGroup> {
//        do {
//            return try await ContactGroupRepository.fetchAll(request: req,
//                                                           on: db)
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func create(content: ContactGroupRequest.Create, on db: Database) async throws -> ContactGroup {
//        do {
//            let response = try await ContactGroupRepository.create(request: content,
//                                                                 on: db)
//            return response
//        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
//            throw CommonError.duplicateName
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
////    func create(content: ContactGroupRequest.Create, on db: Database) async throws -> ContactGroup {
////        do {
////            
////            // fetch by name
////            
////            // prevent duplicatre name
////            
////            //then create new
////            
////            // Initialize the ContactGroup from the validated content
////            let newGroup = ContactGroup(name: content.name, description: content.description)
////            
////            // Attempt to save the new group to the database
////            try await newGroup.save(on: db)
////            
////            // Return the newly created group
////            return newGroup
////        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
////            throw CommonError.duplicateName
////        } catch {
////            // Handle all other errors
////            throw DefaultError.error(message: error.localizedDescription)
////        }
////    }
//    
//    func find(id: UUID, on db: Database) async throws -> ContactGroup {
//        do {
//            guard let group = try await ContactGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
//            
//            return group
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func find(name: String, on db: Database) async throws -> ContactGroup {
//        do {
//            guard let group = try await ContactGroup.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
//            
//            return group
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func update(id: UUID, with content: ContactGroupRequest.Update, on db: Database) async throws -> ContactGroup {
//        do {
//            
//            // Update the supplier group in the database
//            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
//            try await updateBuilder.update()
//            
//            // Retrieve the updated supplier group
//            guard let group = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
//            
//            return group
//        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
//            throw CommonError.duplicateName
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func delete(id: UUID, on db: Database) async throws -> ContactGroup {
//        do {
//            guard let group = try await ContactGroup.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
//            
//            try await group.delete(on: db).get()
//            
//            return group
//        } catch let error as DefaultError {
//            throw error
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func search(req: ContactGroupRequest.Search, on db: Database) async throws -> PaginatedResponse<ContactGroup> {
//        do {
//            let perPage = req.perPage
//            let page = req.page
//            let name = req.name
//            
//            guard
//                name.count > 0,
//                perPage > 0,
//                page > 0
//            else { throw DefaultError.invalidInput }
//            
//            let regexPattern = "(?i)\(name)"  // (?i) makes the regex case-insensitive
//            let query = ContactGroup.query(on: db).filter(\.$name =~ regexPattern)
//            
//            
//            let total = try await query.count()
//            let items = try await sortQuery(query: query,
//                                            sortBy: req.sortBy,
//                                            sortOrder: req.sortOrder,
//                                            page: page,
//                                            perPage: perPage)
//            
//            
//            let response = PaginatedResponse(page: page,
//                                             perPage: perPage,
//                                             total: total,
//                                             items: items)
//            
//            return response
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//}
//
//private extension ContactGroupRepository {
//    func sortQuery(query: QueryBuilder<ContactGroup>,
//                   sortBy: ContactGroupRequest.SortBy,
//                   sortOrder: ContactGroupRequest.SortOrder,
//                   page: Int,
//                   perPage: Int) async throws -> [ContactGroup] {
//        switch sortBy {
//        case .name:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .createdAt:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        }
//    }
//}
//
//extension ContactGroupRepository {
//    
//    // Helper function to update supplier group fields in the database
//    static func updateFieldsBuilder(uuid: UUID, content: ContactGroupRequest.Update, db: Database) -> QueryBuilder<ContactGroup> {
//        let updateBuilder = ContactGroup.query(on: db).filter(\.$id == uuid)
//        
//        if let name = content.name {
//            updateBuilder.set(\.$name, to: name)
//        }
//        
//        if let description = content.description {
//            updateBuilder.set(\.$description, to: description)
//        }
//        
//        return updateBuilder
//    }
//    
//    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<ContactGroup> {
//        return ContactGroup.query(on: db).filter(\.$id == uuid)
//    }
//}
//
