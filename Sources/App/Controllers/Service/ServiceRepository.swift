import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ServiceRepositoryProtocol {
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<Service>
    func create(content: ServiceRepository.Create, on db: Database) async throws -> Service
    func find(id: UUID, on db: Database) async throws -> ServiceResponse
    func find(name: String, on db: Database) async throws -> Service
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> Service
    func delete(id: UUID, on db: Database) async throws -> Service
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<Service>
    func fetchLastedCode(on db: Database) async throws -> Int
}

class ServiceRepository: ServiceRepositoryProtocol {
    
    func fetchAll(req: ServiceRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<Service> {
        do {
            let page = req.page
            let perPage = req.perPage
            
            guard 
                page > 0,
                perPage > 0
            else { throw DefaultError.invalidInput }
            
            let query = Service.query(on: db)
            
            if req.showDeleted {
                query.withDeleted()
            } else {
                query.filter(\.$deletedAt == nil)
            }
            
            let total = try await query.count()        
            //query sorted by name
            let items = try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
            
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
    
    func create(content: ServiceRepository.Create, on db: Database) async throws -> Service {
        do {
            // Initialize the Service from the validated content
            let newModel = Service(number: content.number, 
                                   name: content.name,
                                   description: content.description,
                                   price: content.price,
                                   unit: content.unit,
                                   categoryId: content.categoryId,
                                   images: content.images,
                                   coverImage: content.coverImage,
                                   tags: content.tags)
            
            // Attempt to save the new group to the database
            try await newModel.save(on: db)
            
            // Return the newly created group
            return newModel
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID, on db: Database) async throws -> ServiceResponse {
        do {
            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return ServiceResponse(from: model)
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> Service {
        do {
            guard let group = try await Service.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> Service {
        do {
            
            // Update the supplier group in the database
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            // Retrieve the updated supplier group
            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return model
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func delete(id: UUID, on db: Database) async throws -> Service {
        do {
            guard let group = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await group.delete(on: db).get()
            
            return group
        } catch let error as DefaultError {
            throw error
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<Service> {
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
            let query = Service.query(on: db).filter(\.$name =~ regexPattern)
            
            
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

     //  fetch contact.code which is "S00001" , "S" is prefix and "00001" is number then return max of number
    func fetchLastedCode(on db: Database) async throws -> Int {
        let query = Service.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)

        //query
        let model = try await query.first()        
        
        return model?.number ?? 0
    }
}

extension ServiceRepository {
    
    // Helper function to update supplier group fields in the database
    static func updateFieldsBuilder(uuid: UUID, content: ServiceRepository.Update, db: Database) -> QueryBuilder<Service> {
        let updateBuilder = Service.query(on: db).filter(\.$id == uuid)
        
        if let name = content.name {
            updateBuilder.set(\.$name, to: name)
        }
        
        if let description = content.description {
            updateBuilder.set(\.$description, to: description)
        }
        
        if let price = content.price {
            updateBuilder.set(\.$price, to: price)
        }
        
        if let unit = content.unit {
            updateBuilder.set(\.$unit, to: unit)
        }
        
        if let categoryId = content.categoryId {
            updateBuilder.set(\.$categoryId, to: categoryId)
        }
        
        if let images = content.images {
            updateBuilder.set(\.$images, to: images)
        }
        
        if let coverImage = content.coverImage {
            updateBuilder.set(\.$coverImage, to: coverImage)
        }
        
        if let tags = content.tags {
            updateBuilder.set(\.$tags, to: tags)
        }
        
        return updateBuilder
    }
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Service> {
        return Service.query(on: db).filter(\.$id == uuid)
    }
}

extension ServiceRepository { 

    enum SortBy: String, Codable {
        case name
        case number
        case price
        case createdAt = "created_at"
    }

    enum SortByOrder: String, Codable {
        case asc
        case desc
    }

    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortByOrder
        
        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortByOrder = .asc) {
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
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
            self.sortOrder = (try? container.decode(SortByOrder.self, forKey: .sortOrder)) ?? .asc
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
            case page = "page"
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
        let sortOrder: SortByOrder
        
        init(name: String,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortByOrder = .asc) {
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
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
            self.sortOrder = (try? container.decode(SortByOrder.self, forKey: .sortOrder)) ?? .asc
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
            case name = "name"
            case page = "page"
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }
    
    /*
     // Create.json
     {
     "name": "Transport",
     "description": "Transportation services",
     "price": 100.0,
     "unit": "hour",
     "category_id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
     "images": ["image1.jpg", "image2.jpg"],
     "cover_image": "cover.jpg",
     "tags": ["transport", "service"]
     }
     */
    struct Create: Content, Validatable {
        let name: String
        let number: Int
        let description: String?
        let price: Double
        let unit: String
        let categoryId: UUID?
        let images: [String]
        let coverImage: String?
        let tags: [String]                
        
        init(name: String,
             number: Int,
             description: String? = nil,
             price: Double,
             unit: String,
             categoryId: UUID? = nil,
             images: [String] = [],
             coverImage: String? = nil,
             tags: [String] = []) {
            self.name = name
            self.number = number
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.number = try container.decode(Int.self,
                                               forKey: .number)
            self.description = try? container.decode(String.self,
                                                     forKey: .description)
            self.price = try container.decode(Double.self,
                                              forKey: .price)
            self.unit = try container.decode(String.self,
                                             forKey: .unit)
            self.categoryId = try? container.decode(UUID.self,
                                                    forKey: .categoryId)
            self.images = try container.decode([String].self,
                                               forKey: .images)
            self.coverImage = try? container.decode(String.self,
                                                    forKey: .coverImage)
            self.tags = try container.decode([String].self,
                                             forKey: .tags)                                                                
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case number = "number"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"            
        }
        
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))                            
            validations.add("number", as: Int.self,
                            is: .range(0...))
            validations.add("price", as: Double.self,
                            is: .range(0...))
            
            
            
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        let price: Double?
        let unit: String?
        let categoryId: UUID?
        let images: [String]?
        let coverImage: String?
        let tags: [String]?
        
        init(name: String? = nil,
             description: String? = nil,
             price: Double? = nil,
             unit: String? = nil,
             categoryId: UUID? = nil,
             images: [String]? = nil,
             coverImage: String? = nil,
             tags: [String]? = nil) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(String.self,
                                              forKey: .name)
            self.description = try? container.decode(String.self,
                                                     forKey: .description)
            self.price = try? container.decode(Double.self,
                                               forKey: .price)
            self.unit = try? container.decode(String.self,
                                              forKey: .unit)
            self.categoryId = try? container.decode(UUID.self,
                                                    forKey: .categoryId)
            self.images = try? container.decode([String].self,
                                                forKey: .images)
            self.coverImage = try? container.decode(String.self,
                                                    forKey: .coverImage)
            self.tags = try? container.decode([String].self,
                                              forKey: .tags)                                                                
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"            
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("price", as: Double.self,
                            is: .range(0...))
        }
    }
}
