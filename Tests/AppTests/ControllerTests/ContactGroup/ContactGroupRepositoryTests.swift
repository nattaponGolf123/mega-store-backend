//
//  ContactGroupRepositoryTests.swift
//  
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

@testable import App
import XCTVapor
import MockableTest

final class ContactGroupRepositoryTests: XCTestCase {

    lazy var contactGroupRepository = ContactGroupRepository()
    
//   func testFetchAll_WithValideRequestParam_ShouldRetureValidResponse() async throws {
//      given(contactGroupRepository)
//   }
    
}

/*
 @Mockable
 protocol ContactGroupRepositoryProtocol {
     func fetchAll(req: ContactGroupRepository.Fetch,
                   on db: Database) async throws -> PaginatedResponse<ContactGroup>
     func create(content: ContactGroupRepository.Create, on db: Database) async throws -> ContactGroup
     func find(id: UUID, on db: Database) async throws -> ContactGroup
     func find(name: String, on db: Database) async throws -> ContactGroup
     func update(id: UUID, with content: ContactGroupRepository.Update, on db: Database) async throws -> ContactGroup
     func delete(id: UUID, on db: Database) async throws -> ContactGroup
     func search(req: ContactGroupRepository.Search, on db: Database) async throws -> PaginatedResponse<ContactGroup>
 }

 class ContactGroupRepository: ContactGroupRepositoryProtocol {
     
     func fetchAll(req: ContactGroupRepository.Fetch,
                   on db: Database) async throws -> PaginatedResponse<ContactGroup> {
         do {
             let page = req.page
             let perPage = req.perPage
             
             guard
                 page > 0,
                 perPage > 0
             else { throw DefaultError.invalidInput }
             
             let query = ContactGroup.query(on: db)
             
             if req.showDeleted {
                 query.withDeleted()
             } else {
                 query.filter(\.$deletedAt == nil)
             }
             
             let total = try await query.count()
             let items = try await sortQuery(query: query,
                                             sortBy: req.sortBy,
                                             sortOrder: req.sortOrder,
                                             page: page,
                                             perPage: perPage)
             
             let response = PaginatedResponse(page: page,
                                              perPage: perPage,
                                              total: total,
                                              items: items)
             
             return response
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
     
     func search(req: ContactGroupRepository.Search, on db: Database) async throws -> PaginatedResponse<ContactGroup> {
         do {
             let perPage = req.perPage
             let page = req.page
             let name = req.name
             
             guard
                 name.count > 0,
                 perPage > 0,
                 page > 0
             else { throw DefaultError.invalidInput }
             
             let regexPattern = "(?i)\(name)"  // (?i) makes the regex case-insensitive
             let query = ContactGroup.query(on: db).filter(\.$name =~ regexPattern)
             
             
             let total = try await query.count()
             let items = try await sortQuery(query: query,
                                             sortBy: req.sortBy,
                                             sortOrder: req.sortOrder,
                                             page: page,
                                             perPage: perPage)
             
             
             let response = PaginatedResponse(page: page,
                                              perPage: perPage,
                                              total: total,
                                              items: items)
             
             return response
         } catch {
             // Handle all other errors
             throw DefaultError.error(message: error.localizedDescription)
         }
     }
 }

 private extension ContactGroupRepository {
     func sortQuery(query: QueryBuilder<ContactGroup>,
                    sortBy: ContactGroupRepository.SortBy,
                    sortOrder: ContactGroupRepository.SortOrder,
                    page: Int,
                    perPage: Int) async throws -> [ContactGroup] {
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
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

 */

/*
 
 extension ContactGroupRepository {
     
     enum SortBy: String, Codable {
         case name
         case createdAt = "created_at"
     }
     
     enum SortOrder: String, Codable {
         case asc
         case desc
     }
     
     struct Fetch: Content {
         let showDeleted: Bool
         let page: Int
         let perPage: Int
         let sortBy: SortBy
         let sortOrder: SortOrder

         init(showDeleted: Bool = false,
              page: Int = 1,
              perPage: Int = 20,
              sortBy: SortBy = .name,
              sortOrder: SortOrder = .asc) {
             self.showDeleted = showDeleted
             self.page = page
             self.perPage = perPage
             self.sortBy = sortBy
             self.sortOrder = sortOrder
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
             self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
             self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
             self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .name
             self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
         }
         
         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(showDeleted, forKey: .showDeleted)
             try container.encode(page, forKey: .page)
             try container.encode(perPage, forKey: .perPage)
             try container.encode(sortBy, forKey: .sortBy)
             try container.encode(sortOrder, forKey: .sortOrder)
         }

         enum CodingKeys: String, CodingKey {
             case showDeleted = "show_deleted"
             case page
             case perPage = "per_page"
             case sortBy = "sort_by"
             case sortOrder = "sort_order"
         }
     }

     struct Search: Content {
         let name: String
         let page: Int
         let perPage: Int
         let sortBy: SortBy
         let sortOrder: SortOrder

         init(name: String,
              page: Int = 1,
              perPage: Int = 20,
              sortBy: SortBy = .name,
              sortOrder: SortOrder = .asc) {
             self.name = name
             self.page = page
             self.perPage = perPage
             self.sortBy = sortBy
             self.sortOrder = sortOrder
         }

         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.name = try container.decode(String.self, forKey: .name)
             self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
             self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
             self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .name
             self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
         }

         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(name, forKey: .name)
             try container.encode(page, forKey: .page)
             try container.encode(perPage, forKey: .perPage)
             try container.encode(sortBy, forKey: .sortBy)
             try container.encode(sortOrder, forKey: .sortOrder)
         }

         enum CodingKeys: String, CodingKey {
             case name
             case page
             case perPage = "per_page"
             case sortBy = "sort_by"
             case sortOrder = "sort_order"
         }
     }

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

 */
