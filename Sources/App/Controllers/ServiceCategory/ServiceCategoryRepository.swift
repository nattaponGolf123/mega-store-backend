import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ServiceCategoryRepositoryProtocol {
    func fetchAll(req: ServiceCategoryRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ServiceCategory>
    func create(content: ServiceCategoryRepository.Create, on db: Database) async throws -> ServiceCategory
    func find(id: UUID, on db: Database) async throws -> ServiceCategory
    func find(name: String, on db: Database) async throws -> ServiceCategory
    func update(id: UUID, with content: ServiceCategoryRepository.Update, on db: Database) async throws -> ServiceCategory
    func delete(id: UUID, on db: Database) async throws -> ServiceCategory
    func search(req: ServiceCategoryRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceCategory>
}

class ServiceCategoryRepository: ServiceCategoryRepositoryProtocol {
     
    func fetchAll(req: ServiceCategoryRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ServiceCategory> {
    do {
        let page = req.page
        let perPage = req.perPage

        guard 
            page > 0,
            perPage > 0
        else { throw DefaultError.invalidInput }
        
        let query = ServiceCategory.query(on: db)
        
        if req.showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }
        
        let total = try await query.count()
        let items = try await query.range((page - 1) * perPage..<(page * perPage)).all()
        
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

    func create(content: ServiceCategoryRepository.Create, on db: Database) async throws -> ServiceCategory {
        do {
            // Initialize the ServiceCategory from the validated content
            let newGroup = ServiceCategory(name: content.name, description: content.description)
    
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

    func find(id: UUID, on db: Database) async throws -> ServiceCategory {
        do {
            guard let group = try await ServiceCategory.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return group
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ServiceCategory {
        do {
            guard let group = try await ServiceCategory.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func update(id: UUID, with content: ServiceCategoryRepository.Update, on db: Database) async throws -> ServiceCategory {
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

    func delete(id: UUID, on db: Database) async throws -> ServiceCategory {
        do {
            guard let group = try await ServiceCategory.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await group.delete(on: db).get()
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func search(req: ServiceCategoryRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceCategory> {
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
        let query = ServiceCategory.query(on: db).filter(\.$name =~ regexPattern)
        
        
        let total = try await query.count()
        let items = try await query.range((page - 1) * perPage..<(page * perPage)).all()
        
        
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

extension ServiceCategoryRepository {
    
    // Helper function to update supplier group fields in the database
    static func updateFieldsBuilder(uuid: UUID, content: ServiceCategoryRepository.Update, db: Database) -> QueryBuilder<ServiceCategory> {
        let updateBuilder = ServiceCategory.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<ServiceCategory> {
        return ServiceCategory.query(on: db).filter(\.$id == uuid)
    }
}

extension ServiceCategoryRepository { 

    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int

        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20) {
            self.showDeleted = showDeleted
            self.page = page
            self.perPage = perPage
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }

        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page = "page"
            case perPage = "per_page"
        }
    }   

    struct Search: Content {
        let name: String
        let page: Int
        let perPage: Int

        init(name: String,
             page: Int = 1,
             perPage: Int = 20) {
            self.name = name
            self.page = page
            self.perPage = perPage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case page = "page"
            case perPage = "per_page"
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
