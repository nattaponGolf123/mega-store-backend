import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol ProductRepositoryProtocol {
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func create(content: ProductRepository.Create, on db: Database) async throws -> ProductResponse
    func find(id: UUID, on db: Database) async throws -> ProductResponse
    func find(name: String, on db: Database) async throws -> ProductResponse
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> ProductResponse
    func delete(id: UUID, on db: Database) async throws -> ProductResponse
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductResponse>
    func linkContact(id: UUID, contactId: UUID, on db: Database) async throws -> ProductResponse
    func deleteContact(id: UUID, contactId: UUID, on db: Database) async throws -> ProductResponse
    func fetchLastedNumber(on db: Database) async throws -> Int
    
    func fetchVariantLastedNumber(id: UUID, on db: Database) async throws -> Int
    func createVariant(id: UUID, content: ProductRepository.CreateVariant, on db: Database) async throws -> ProductResponse
    func updateVariant(id: UUID, variantId: UUID, with content: ProductRepository.UpdateVariant, on db: Database) async throws -> ProductResponse
    func deleteVariant(id: UUID, variantId: UUID, on db: Database) async throws -> ProductResponse    

}

class ProductRepository: ProductRepositoryProtocol {
    
    func fetchAll(req: ProductRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<ProductResponse> {
        do {
            let page = req.page
            let perPage = req.perPage
            let sortBy = req.sortBy
            let sortOrder = req.sortOrder
            
            guard page > 0, perPage > 0 else { throw DefaultError.invalidInput }
            
            let query = Product.query(on: db)
            
            if req.showDeleted {
                query.withDeleted()
            } else {
                query.filter(\.$deletedAt == nil)
            }
            
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder,
                                            page: page,
                                            perPage: perPage)
            
            let responseItems = items.map { ProductResponse(from: $0) }
            let response = PaginatedResponse(page: page, perPage: perPage, total: total, items: responseItems)
            
            return response
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func create(content: ProductRepository.Create, on db: Database) async throws -> ProductResponse {
        do {
            let lastedNumber = try await fetchLastedNumber(on: db)
            let nextNumber = lastedNumber + 1
            let newModel = Product(number: nextNumber,
                                   name: content.name,
                                   description: content.description, 
                                   price: content.price,
                                   images: content.images)
            
            try await newModel.save(on: db)
            
            return ProductResponse(from: newModel)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(name: String, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func update(id: UUID, with content: ProductRepository.Update, on db: Database) async throws -> ProductResponse {
        do {
            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
            try await updateBuilder.update()
            
            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
            
            return ProductResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
            throw CommonError.duplicateName
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func delete(id: UUID, on db: Database) async throws -> ProductResponse {
        do {
            guard let model = try await Product.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
            
            try await model.delete(on: db).get()
            
            return ProductResponse(from: model)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func search(req: ProductRepository.Search, on db: Database) async throws -> PaginatedResponse<ProductResponse> {
        do {
            let perPage = req.perPage
            let page = req.page
            let keyword = req.q
            let sort = req.sortBy
            let order = req.sortOrder
            
            guard
                keyword.count > 0,
                perPage > 0,
                page > 0
            else { throw DefaultError.invalidInput }

            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
            let query = Product.query(on: db).group(.or) { or in
                or.filter(\.$name =~ regexPattern)
                or.filter(\.$description =~ regexPattern)
                if let number = Int(keyword) {
                    or.filter(\.$number == number)
                }
             }
                    
            let total = try await query.count()
            let items = try await sortQuery(query: query,
                                            sortBy: sort,
                                            sortOrder: order,
                                            page: page,
                                            perPage: perPage)
            let responseItems = items.map { ProductResponse(from: $0) }
            let response = PaginatedResponse(page: page,
                                             perPage: perPage,
                                             total: total,
                                             items: responseItems)
            
            return response
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func linkContact(id: UUID, contactId: UUID, on db: Database) async throws -> ProductResponse {
        do {                        
            guard 
                let model = try await Self.getByIDBuilder(uuid: id, db: db).first(),
                // verify is exist contact and not deleted
                let contact = try await Contact.query(on: db).filter(\.$id == contactId).first()                
            else { throw DefaultError.notFound }

            guard 
                model.suppliers.contains(contactId) == false 
            else { throw DefaultError.error(message: "Contact already linked") }

            let updateSppliers: [UUID] = model.suppliers + [contactId]
            model.suppliers = updateSppliers

            try await model.save(on: db)
            
            return ProductResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError {
            throw error
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func deleteContact(id: UUID, contactId: UUID, on db: any FluentKit.Database) async throws -> ProductResponse {
        do {                        
            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }

            guard 
                model.suppliers.contains(contactId) 
            else { throw DefaultError.error(message: "Contact not found") }

            model.suppliers.removeAll() { $0 == contactId }            

            try await model.save(on: db)
            
            return ProductResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError {
            throw error
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func fetchLastedNumber(on db: Database) async throws -> Int {
        let query = Product.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)

        let model = try await query.first()
        
        return model?.number ?? 0
    }
    
    // MARK: Variant
    func fetchVariantLastedNumber(id: UUID, on db: Database) async throws -> Int {
        do {
            guard 
                let model = try await Self.getByIDBuilder(uuid: id, db: db).first()             
            else { throw DefaultError.notFound }

            let variants: [ProductVariant] = model.variants
            let lastedNumber = variants.map { $0.number }.max() ?? 0

            return lastedNumber
        } catch let error as FluentMongoDriver.FluentMongoError {
            throw error
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }

    func createVariant(id: UUID, content: ProductRepository.CreateVariant, on db: Database) async throws -> ProductResponse {
        do {                        
            guard 
                let model = try await Self.getByIDBuilder(uuid: id, db: db).first()             
            else { throw DefaultError.notFound }

            let curentNumber = try await fetchVariantLastedNumber(id: id, on: db)
            let nextNumber = curentNumber + 1

            let newVariant = ProductVariant(number: nextNumber,
                                            name: content.name,
                                            sku: content.sku,
                                            price: content.price,
                                            description: content.description,
                                            image: content.image,
                                            color: content.color,
                                            barcode: content.barcode,
                                            dimensions: content.dimensions)


            try await model.save(on: db)
            
            return ProductResponse(from: model)
        } catch let error as FluentMongoDriver.FluentMongoError {
            throw error
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func updateVariant(id: UUID, variantId: UUID, with content: ProductRepository.UpdateVariant, on db: Database) async throws -> ProductResponse {
        do {
            guard 
                let product = try await Product.query(on: db).filter(\.$id == id).first(),
                let variant = product.variants.first(where: { $0.id == variantId })
            else {
                throw DefaultError.notFound
            }            
            
            if let name = content.name {
                variant.name = name
            }

            if let sku = content.sku {
                variant.sku = sku
            }

            if let price = content.price {
                variant.price = price
            }

            if let description = content.description {
                variant.description = description
            }

            if let image = content.image {
                variant.image = image
            }

            if let color = content.color {
                variant.color = color
            }

            if let barcode = content.barcode {
                variant.barcode = barcode
            }

            if let dimensions = content.dimensions {
                variant.dimensions = dimensions
            }

            //replace variant in product.variants with match uuid
            product.variants = product.variants.map({ $0.id == variant.id ? variant : $0 })
            
            try await product.save(on: db)
            
            return ProductResponse(from: product)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }

    }
    
    func deleteVariant(id: UUID, variantId: UUID, on db: Database) async throws -> ProductResponse {        
        do {
            guard 
                let product = try await Product.query(on: db).filter(\.$id == id).first(),
                let variant = product.variants.first(where: { $0.id == variantId })
            else {
                throw DefaultError.notFound
            }            

            product.variants.removeAll() { $0.id == variantId }

            try await product.save(on: db)
            
            return ProductResponse(from: product)
        } catch let error as DefaultError {
            throw error
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
}


private extension ProductRepository {
    func sortQuery(query: QueryBuilder<Product>,
                   sortBy: ProductRepository.SortBy,
                   sortOrder: ProductRepository.SortOrder,
                   page: Int,
                   perPage: Int) async throws -> [Product] {
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
        case .number:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .price:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$price).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$price, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .categoryId:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$categoryId).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$categoryId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        }
    }
}

extension ProductRepository {
    
    static func updateFieldsBuilder(uuid: UUID, content: ProductRepository.Update, db: Database) -> QueryBuilder<Product> {
        let updateBuilder = Product.query(on: db).filter(\.$id == uuid)
        
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
    
    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Product> {
        return Product.query(on: db).filter(\.$id == uuid)
    }
}

/*
 final class ProductVariant:Model, Content {
     static let schema = "ProductVariant"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "number")
     var number: Int

     @Field(key: "name")
     var name: String
     
     @Field(key: "sku")
     var sku: String?
     
     @Field(key: "price")
     var price: Double
     
     @Field(key: "description")
     var description: String?
     
     @Field(key: "image")
     var image: String?
     
     @Field(key: "color")
     var color: String?
     
     @Field(key: "barcode")
     var barcode: String?
     
     @Field(key: "dimensions")
     var dimensions: ProductDimension?
     
     @Timestamp(key: "created_at",
                on: .create,
                format: .iso8601)
     var createdAt: Date?
     
     @Timestamp(key: "updated_at",
                on: .update,
                format: .iso8601)
     var updatedAt: Date?
     
     @Timestamp(key: "deleted_at",
                on: .delete,
                format: .iso8601)
     var deletedAt: Date?
     
     init() { }
     
     init(id: UUID? = nil,
          number: Int = 1,
          name: String,
          sku: String? = nil,
          price: Double = 0,
          description: String? = nil,
          image: String? = nil,
          color: String? = nil,
          barcode: String? = nil,
          dimensions: ProductDimension? = nil,
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil) {
         
         self.id = id ?? .init()
         self.number = number
         self.name = name
         self.description = description
         self.sku = sku
         self.price = price
         self.image = image
         self.color = color
         self.barcode = barcode
         self.dimensions = dimensions
         self.createdAt = createdAt ?? .init()
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
     }

 }
 */

/*
final class Product: Model, Content {
    static let schema = "Products"
   
    @ID(key: .id)
    var id: UUID?

    @Field(key: "number")
    var number: Int

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String?

    @Field(key: "unit")
    var unit: String?

    @Field(key: "price")
    var price: Double

    @Field(key: "category_id")
    var categoryId: UUID?

    @Field(key: "manufacturer")
    var manufacturer: String?

    @Field(key: "barcode")
    var barcode: String?

    @Timestamp(key: "created_at",
           on: .create,
           format: .iso8601)
    var createdAt: Date?

    @Timestamp(key: "updated_at",
           on: .update,
           format: .iso8601)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", 
           on: .delete, 
           format: .iso8601)
    var deletedAt: Date?

    @Field(key: "images")
    var images: [String]

    @Field(key: "cover_image")
    var coverImage: String?

    @Field(key: "tags")
    var tags: [String]

    @Field(key: "suppliers")
    var suppliers: [UUID]

    @Field(key: "variants")
    var variants: [ProductVariant]

    init() { }

    init(id: UUID? = nil,
         number: Int = 1,
         name: String,
         description: String? = nil,
         unit: String? = nil,
         price: Double,
         categoryId: UUID? = nil,
         manufacturer: String? = nil,
         barcode: String? = nil,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         suppliers: [UUID] = [],
         variants: [ProductVariant] = []) {
        self.id = id ?? .init()
        self.number = number
        self.name = name
        self.description = description
        self.unit = unit
        self.price = price
        self.categoryId = categoryId
        self.manufacturer = manufacturer
        self.barcode = barcode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.images = images
        self.coverImage = coverImage
        self.tags = tags
        self.suppliers = suppliers
        self.variants = variants
    }

}
*/

