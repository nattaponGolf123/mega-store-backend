import Foundation
import Vapor

protocol ProductCategoryValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ProductCategoryRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductCategoryRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ProductCategoryValidator: ProductCategoryValidatorProtocol {
    typealias CreateContent = ProductCategoryRepository.Create
    typealias UpdateContent = ProductCategoryRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming ProductCategory
            let content: ProductCategoryValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the ProductCategory directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ProductCategoryRepository.Update) {
        typealias UpdateProductCategory = ProductCategoryRepository.Update
        do {
            // Decode the incoming ProductCategory and validate it
            let content: UpdateProductCategory = try req.content.decode(UpdateProductCategory.self)
            try UpdateProductCategory.validate(content: req)
            
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
protocol ProductCategoryRepositoryProtocol {
    func fetchAll(req: ProductCategoryRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductCategory>
    func create(content: ProductCategoryRepository.Create, on db: Database) async throws -> ProductCategory
    func find(id: UUID, on db: Database) async throws -> ProductCategory
    func find(name: String, on db: Database) async throws -> ProductCategory
    func update(id: UUID, with content: ProductCategoryRepository.Update, on db: Database) async throws -> ProductCategory
    func delete(id: UUID, on db: Database) async throws -> ProductCategory
    func search(req: ProductCategoryRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductCategory>
}
extension ProductCategoryRepository { 

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
