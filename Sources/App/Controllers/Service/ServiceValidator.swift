import Foundation
import Vapor

protocol ServiceValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ServiceRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ServiceRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ServiceValidator: ServiceValidatorProtocol {
    typealias CreateContent = ServiceRepository.Create
    typealias UpdateContent = ServiceRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming Service
            let content: ServiceValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the Service directly
            try CreateContent.validate(content: req)
            
            return content
        } catch let error as ValidationsError {
            // Parse and throw a more specific input validation error if validation fails
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            // Handle all other errors
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ServiceRepository.Update) {
        typealias UpdateService = ServiceRepository.Update
        do {
            // Decode the incoming Service and validate it
            let content: UpdateService = try req.content.decode(UpdateService.self)
            try UpdateService.validate(content: req)
            
            // Extract the ID from the request's parameters
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id"), let uuid = UUID(id) else { throw DefaultError.invalidInput }
        
        return uuid
    }

    func validateSearchQuery(_ req: Request) throws -> String {
        guard 
            let search = req.query[String.self, at: "q"],
            !search.isEmpty
            else { throw DefaultError.invalidInput }
        
        return search
    }
}
/*
protocol ServiceRepositoryProtocol {
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<Service>
    func create(content: ServiceRepository.Create, on db: Database) async throws -> Service
    func find(id: UUID, on db: Database) async throws -> Service
    func find(name: String, on db: Database) async throws -> Service
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> Service
    func delete(id: UUID, on db: Database) async throws -> Service
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<Service>
}
extension ServiceRepository { 

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
