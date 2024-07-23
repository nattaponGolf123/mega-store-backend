import Foundation
import Vapor
import Mockable

@Mockable
protocol ContactGroupValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactGroupRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)
    func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search
}

class ContactGroupValidator: ContactGroupValidatorProtocol {
    typealias CreateContent = ContactGroupRequest.Create
    typealias UpdateContent = (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)

    func validateCreate(_ req: Request) throws -> CreateContent {
        try CreateContent.validate(content: req)
        
        return try req.content.decode(CreateContent.self)
        
//        do {
//            // Decode the incoming ContactGroup
//            let content: ContactGroupValidator.CreateContent = try req.content.decode(CreateContent.self)  
//
//            // Validate the ContactGroup directly
//            try CreateContent.validate(content: req)
//            
//            return content
//        } catch let error as ValidationsError {
//            // Parse and throw a more specific input validation error if validation fails
//            let errors = InputError.parse(failures: error.failures)
//            throw InputValidateError.inputValidateFailed(errors: errors)
//        } catch {
//            // Handle all other errors
//            throw DefaultError.invalidInput
//        }
    }

    func validateUpdate(_ req: Request) throws -> UpdateContent {
        try ContactGroupRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = ContactGroupRequest.FetchById(id: id)
        let content = try req.content.decode(ContactGroupRequest.Update.self)
        
        return (fetchById, content)
    }
        
//        typealias UpdateContactGroup = ContactGroupRequest.Update
//        do {
//            // Decode the incoming ContactGroup and validate it
//            let content: UpdateContactGroup = try req.content.decode(UpdateContactGroup.self)
//            try UpdateContactGroup.validate(content: req)
//            
//            // Extract the ID from the request's parameters
//            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
//            let fetchById = ContactGroupRequest.FetchById(id: id)
//            
//            return (fetchById, content)
//        } catch let error as ValidationsError {
//            let errors = InputError.parse(failures: error.failures)
//            throw InputValidateError.inputValidateFailed(errors: errors)
//        } catch {
//            throw DefaultError.invalidInput
//        }
//    }

    func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById {
        do {
            return try req.query.decode(ContactGroupRequest.FetchById.self)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search {
        do {
            let content = try req.query.decode(ContactGroupRequest.Search.self)
            
            guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
            
            return content
        }
        catch {
            throw DefaultError.invalidInput
        }
    }
}
/*
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
extension ContactGroupRepository { 

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
             perPage: Int = 20) {
            self.name = name
            self.perPage = perPage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20            
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(perPage, forKey: .perPage)
        }

        enum CodingKeys: String, CodingKey {
            case name = "name"
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

*/
