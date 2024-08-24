import XCTest
import Vapor
@testable import App

final class ServiceRequestTests: XCTestCase {
    
    // MARK: - Create Tests
    
    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        let categoryId = UUID()
        let create = ServiceRequest.Create(
            name: "Test Service",
            description: "Test description",
            price: 100.00,
            unit: "hour",
            categoryId: categoryId,
            images: ["image1", "image2"],
            coverImage: "coverImage",
            tags: ["tag1", "tag2"]
        )
        
        XCTAssertEqual(create.name, "Test Service")
        XCTAssertEqual(create.description, "Test description")
        XCTAssertEqual(create.price, 100.00)
        XCTAssertEqual(create.unit, "hour")
        XCTAssertEqual(create.categoryId, categoryId)
        XCTAssertEqual(create.images, ["image1", "image2"])
        XCTAssertEqual(create.coverImage, "coverImage")
        XCTAssertEqual(create.tags, ["tag1", "tag2"])
        
    }
    
    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let categoryId = UUID()
        let create = ServiceRequest.Create(
            name: "Test Service",
            description: "Test description",
            price: 100.00,
            unit: "hour",
            categoryId: categoryId,
            images: ["image1", "image2"],
            coverImage: "coverImage",
            tags: ["tag1", "tag2"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(create)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Test Service")
        XCTAssertEqual(jsonObject?["description"] as? String, "Test description")
        XCTAssertEqual(jsonObject?["price"] as? Double, 100.00)
        XCTAssertEqual(jsonObject?["unit"] as? String, "hour")
        XCTAssertEqual(jsonObject?["category_id"] as? String, categoryId.uuidString)
        XCTAssertEqual(jsonObject?["images"] as? [String], ["image1", "image2"])
        XCTAssertEqual(jsonObject?["cover_image"] as? String, "coverImage")
        XCTAssertEqual(jsonObject?["tags"] as? [String], ["tag1", "tag2"])
        
    }
    
    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let categoryId = UUID()
        let json = """
        {
            "name": "Test Service",
            "description": "Test description",
            "price": 100.00,
            "unit": "hour",
            "category_id": "\(categoryId.uuidString)",
            "images": ["image1", "image2"],
            "cover_image": "coverImage",
            "tags": ["tag1", "tag2"]
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let create = try decoder.decode(ServiceRequest.Create.self, from: data)
        
        XCTAssertEqual(create.name, "Test Service")
        XCTAssertEqual(create.description, "Test description")
        XCTAssertEqual(create.price, 100.00)
        XCTAssertEqual(create.unit, "hour")
        XCTAssertEqual(create.categoryId, categoryId)
        XCTAssertEqual(create.images, ["image1", "image2"])
        XCTAssertEqual(create.coverImage, "coverImage")
        XCTAssertEqual(create.tags, ["tag1", "tag2"])
        
    }
      
    // MARK: - Update Tests

    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let categoryId = UUID()
        let update = ServiceRequest.Update(
            name: "Test Service",
            description: "Test description",
            price: 100.00,
            unit: "hour",
            categoryId: categoryId,
            images: ["image1", "image2"],
            coverImage: "coverImage",
            tags: ["tag1", "tag2"]
        )
        
        XCTAssertEqual(update.name, "Test Service")
        XCTAssertEqual(update.description, "Test description")
        XCTAssertEqual(update.price, 100.00)
        XCTAssertEqual(update.unit, "hour")
        XCTAssertEqual(update.categoryId, categoryId)
        XCTAssertEqual(update.images, ["image1", "image2"])
        XCTAssertEqual(update.coverImage, "coverImage")
        XCTAssertEqual(update.tags, ["tag1", "tag2"])
        
    }
    
    // write complete of testUpdateEncode_WithValidInstance_ShouldReturnJSON
    func testUpdateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let update = ServiceRequest.Update(
            name: "Test Service",
            description: "Test description",
            price: 100.00,
            unit: "hour",
            categoryId: UUID(),
            images: ["image1", "image2"],
            coverImage: "coverImage",
            tags: ["tag1", "tag2"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(update)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Test Service")
        XCTAssertEqual(jsonObject?["description"] as? String, "Test description")
        XCTAssertEqual(jsonObject?["price"] as? Double, 100.00)
        XCTAssertEqual(jsonObject?["unit"] as? String, "hour")
        XCTAssertEqual(jsonObject?["category_id"] as? String, update.categoryId?.uuidString)
        XCTAssertEqual(jsonObject?["images"] as? [String], ["image1", "image2"])
        XCTAssertEqual(jsonObject?["cover_image"] as? String, "coverImage")
        XCTAssertEqual(jsonObject?["tags"] as? [String], ["tag1", "tag2"])
    }
    
    // write complete code of testUpdateDecode_WithValidJSON_ShouldReturnInstance
    func testUpdateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let categoryId = UUID()
        let json = """
        {
            "name": "Test Service",
            "description": "Test description",
            "price": 100.00,
            "unit": "hour",
            "category_id": "\(categoryId.uuidString)",
            "images": ["image1", "image2"],
            "cover_image": "coverImage",
            "tags": ["tag1", "tag2"]
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let update = try decoder.decode(ServiceRequest.Update.self, from: data)
        
        XCTAssertEqual(update.name, "Test Service")
        XCTAssertEqual(update.description, "Test description")
        XCTAssertEqual(update.price, 100.00)
        XCTAssertEqual(update.unit, "hour")
        XCTAssertEqual(update.categoryId, categoryId)
        XCTAssertEqual(update.images, ["image1", "image2"])
        XCTAssertEqual(update.coverImage, "coverImage")
        XCTAssertEqual(update.tags, ["tag1", "tag2"])
    }

}
