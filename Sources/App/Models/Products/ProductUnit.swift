import Vapor
import Fluent

final class ProductUnit: Model, Content {
    static let schema = "ProductUnits"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String    
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete, format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil, 
         name: String,
         createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt ?? Date()
    }
}