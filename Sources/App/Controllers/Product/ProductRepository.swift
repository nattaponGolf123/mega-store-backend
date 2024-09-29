import Foundation
import Vapor
import Fluent
import Mockable

@Mockable
protocol ProductRepositoryProtocol {
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    typealias CreateVariant = (id: GeneralRequest.FetchById, content: ProductRequest.CreateVariant)
    typealias UpdateVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById, content: ProductRequest.UpdateVariant)
    typealias DeleteVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById)
    
    func fetchAll(request: FetchAll,
                  on db: Database) async throws -> PaginatedResponse<Product>
    func fetchById(request: GeneralRequest.FetchById,
                  on db: Database) async throws -> Product
    func fetchByName(request: GeneralRequest.FetchByName,
                     on db: Database) async throws -> Product
    
    func create(request: ProductRequest.Create,
                on db: Database) async throws -> Product
    func update(byId: GeneralRequest.FetchById,
                request: ProductRequest.Update,
                on db: Database) async throws -> Product
    func delete(byId: GeneralRequest.FetchById,
                on db: Database) async throws -> Product
    
    func search(request: Search,
                on db: Database) async throws -> PaginatedResponse<Product>
    
    func fetchLastedNumber(on db: Database) async throws -> Int
    
    func fetchVariantLastedNumber(byId: GeneralRequest.FetchById,
                                  on db: Database) async throws -> Int
    func createVariant(byId: GeneralRequest.FetchById,
                       request: ProductRequest.CreateVariant,
                       on db: Database) async throws -> Product
    func updateVariant(byId: GeneralRequest.FetchById,
                       variantId: GeneralRequest.FetchById,
                       request: ProductRequest.UpdateVariant,
                       on db: Database) async throws -> Product
    func deleteVariant(byId: GeneralRequest.FetchById,
                       variantId: GeneralRequest.FetchById,
                       on db: Database) async throws -> Product

}

class ProductRepository: ProductRepositoryProtocol {
    
    private var productCategoryRepository: ProductCategoryRepositoryProtocol
    
    init(productCategoryRepository: ProductCategoryRepositoryProtocol = ProductCategoryRepository()) {
        self.productCategoryRepository = productCategoryRepository
    }
    
    func fetchAll(request: FetchAll, 
                  on db: any FluentKit.Database) async throws -> PaginatedResponse<Product> {
        let query = Product.query(on: db)
        
        if request.showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }
        
        let total = try await query.count()
        let items = try await sortQuery(query: query,
                                        sortBy: request.sortBy,
                                        sortOrder: request.sortOrder,
                                        page: request.page,
                                        perPage: request.perPage)
        
        let response = PaginatedResponse(page: request.page,
                                         perPage: request.perPage,
                                         total: total,
                                         items: items)
        return response
    }
    
    func fetchById(request: GeneralRequest.FetchById,
                  on db: any FluentKit.Database) async throws -> Product {
        guard
            let found = try await Product.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func fetchByName(request: GeneralRequest.FetchByName, on db: any FluentKit.Database) async throws -> Product {
        guard
            let found = try await Product.query(on: db).filter(\.$name == request.name).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func create(request: ProductRequest.Create,
                on db: any FluentKit.Database) async throws -> Product {
        // prevent duplicate name
        if let _ = try? await fetchByName(request: .init(name: request.name),
                                          on: db) {
            throw CommonError.duplicateName
        }
        
        if let groupId = request.categoryId {
            guard
                let _ = try? await productCategoryRepository.fetchById(request: .init(id: groupId),
                                                                       on: db)
            else { throw DefaultError.notFound }
        }
        
        let lastedNumber = try await fetchLastedNumber(on: db)
        let nextNumber = lastedNumber + 1
        
        let product = Product(number: nextNumber, 
                              name: request.name,
                              description: request.description,
                              unit: request.unit,
                              price: request.price,
                              categoryId: request.categoryId,
                              manufacturer: request.manufacturer,
                              barcode: request.barcode,
                              images: request.images,
                              coverImage: request.coverImage,
                              tags: request.tags)
        try await product.save(on: db)
        return product
    }
    
    func update(byId: GeneralRequest.FetchById,
                request: ProductRequest.Update,
                on db: any FluentKit.Database) async throws -> Product {
        let product = try await fetchById(request: .init(id: byId.id), 
                                          on: db)
        
        if let name = request.name {
            // prevent duplicate name
            if let _ = try? await fetchByName(request: .init(name: name),
                                              on: db) {
                throw CommonError.duplicateName
            }
            
            product.name = name
        }
        
        if let categoryId = request.categoryId {
            // try to fetch category id to check is exist
            guard
                let _ = try? await productCategoryRepository.fetchById(request: .init(id: categoryId),
                                                                   on: db)
            else { throw DefaultError.notFound }
            
            product.$category.id = categoryId
        }
        
        if let description = request.description {
            product.descriptionInfo = description
        }
        
        if let price = request.price {
            product.price = price
        }
        
        if let unit = request.unit {
            product.unit = unit
        }
        
        if let images = request.images {
            product.images = images
        }
        
        if let coverImage = request.coverImage {
            product.coverImage = coverImage
        }
        
        if let tags = request.tags {
            product.tags = tags
        }
        
        if let manufacturer = request.manufacturer {
            product.manufacturer = manufacturer
        }
        
        if let barcode = request.barcode {
            product.barcode = barcode
        }
        
        try await product.save(on: db)
        return product
    }
    
    func delete(byId: GeneralRequest.FetchById,
                on db: any FluentKit.Database) async throws -> Product {
        let product = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        try await product.delete(on: db)
        return product
    }
    
    func search(request: Search,
                on db: any FluentKit.Database) async throws -> PaginatedResponse<Product> {
        let q = request.query
        let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
        let query = Product.query(on: db).group(.or) { or in
            or.filter(\.$name =~ regexPattern)
            if let number = Int(q) {
                or.filter(\.$number == number)
            }
            or.filter(\.$descriptionInfo =~ regexPattern)
            or.filter(\.$barcode == q)
            or.filter(\.$manufacturer =~ regexPattern)            
        }
        
        let total = try await query.count()
        let items = try await sortQuery(query: query,
                                        sortBy: request.sortBy,
                                        sortOrder: request.sortOrder,
                                        page: request.page,
                                        perPage: request.perPage)
        
        let response = PaginatedResponse(page: request.page,
                                         perPage: request.perPage,
                                         total: total,
                                         items: items)
        return response
    }
    
    func fetchLastedNumber(on db: any FluentKit.Database) async throws -> Int {
        let query = Product.query(on: db).withDeleted()
        query.sort(\.$number, .descending)
        query.limit(1)
        
        let model = try await query.first()
        
        return model?.number ?? 0
    }
    
    // MARK: Variant
    
    func fetchVariantLastedNumber(byId: GeneralRequest.FetchById,
                                  on db: any FluentKit.Database) async throws -> Int {
        let model = try await fetchById(request: .init(id: byId.id),
                                          on: db)
        
        let variants: [ProductVariant] = model.variants
        let lastedNumber = variants.map { $0.number }.max() ?? 0
        
        return lastedNumber
    }
    
    func createVariant(byId: GeneralRequest.FetchById,
                       request: ProductRequest.CreateVariant,
                       on db: any FluentKit.Database) async throws -> Product {
        let model = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        
        let variantLastedNumber = try await fetchVariantLastedNumber(byId: byId, 
                                                                     on: db)
        let nextNumber = variantLastedNumber + 1
        
        let existModels = model.variants.filter({$0.deletedAt == nil })
        
        // prevent duplicate name
        if existModels.contains(where: { $0.name == request.name }) {
            throw CommonError.duplicateName
        }
        
        //prevent duplicate color
        if existModels.contains(where: { $0.color == request.color }) {
            throw CommonError.duplicateColor
        }
        
        let variant = ProductVariant(number: nextNumber,
                                     name: request.name,
                                     sku: request.sku,
                                     price: request.price,
                                     description: request.description,
                                     image: request.image,
                                     color: request.color,
                                     barcode: request.barcode,
                                     dimensions: request.dimensions)
        model.variants.append(variant)
        
        try await model.save(on: db)
        return model
    }
    
    func updateVariant(byId: GeneralRequest.FetchById, 
                       variantId: GeneralRequest.FetchById,
                       request: ProductRequest.UpdateVariant,
                       on db: any FluentKit.Database) async throws -> Product {
        let model = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        
        let existModels = model.variants.filter({$0.deletedAt == nil })
        
        guard let variant = existModels.first(where: { $0.id == variantId.id }) else {
            throw DefaultError.notFound
        }
        
        if let name = request.name {
            // prevent duplicate name
            if existModels.contains(where: { $0.name == name }) {
                throw CommonError.duplicateName
            }
            
            variant.name = name
        }
        
        if let sku = request.sku {
            variant.sku = sku
        }
        
        if let price = request.price {
            variant.price = price
        }
        
        if let description = request.description {
            variant.description = description
        }
        
        if let image = request.image {
            variant.image = image
        }
        
        if let color = request.color {
            variant.color = color
        }
        
        if let barcode = request.barcode {
            variant.barcode = barcode
        }
        
        if let dimensions = request.dimensions {
            variant.dimensions = dimensions
        }
        
        try await model.save(on: db)
        return model
    }
    
    func deleteVariant(byId: GeneralRequest.FetchById,
                       variantId: GeneralRequest.FetchById,
                       on db: any FluentKit.Database) async throws -> Product {
        let model = try await fetchById(request: byId,
                                        on: db)
        
        let existModels = model.variants.filter({$0.deletedAt == nil })
        
        guard let variant = existModels.first(where: { $0.id == variantId.id }) else {
            throw DefaultError.notFound
        }
        
        // soft delete
        variant.updatedAt = Date()
        variant.deletedAt = Date()
        
        try await model.save(on: db)
        return model
    }
    
}


private extension ProductRepository {
    func sortQuery(query: QueryBuilder<Product>,
                   sortBy: SortBy,
                   sortOrder: SortOrder,
                   page: Int,
                   perPage: Int) async throws -> [Product] {
        
        let pageIndex = (page - 1)
        let pageStart = pageIndex * perPage
        let pageEnd = pageStart + perPage
        
        let range = pageStart..<pageEnd
                        
        query.with(\.$category)
        
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
        case .groupName:
            switch sortOrder {
            case .asc:
                return try await query.sort(ServiceCategory.self, \.$name).range(range).all()
            case .desc:
                return try await query.sort(ServiceCategory.self, \.$name, .descending).range(range).all()
            }
        default:
            return try await query.range(range).all()
        }
    }
}

