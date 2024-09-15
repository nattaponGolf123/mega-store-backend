
import XCTest
import Vapor
@testable import App

final class ProductRequestTests: XCTestCase {
    
    // MARK: - Create Tests
    
    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        let categoryId = UUID()
        let create = ProductRequest.Create(
            name: "Test Product",
            description: "Test product description",
            price: 100.00,
            unit: "kg",
            categoryId: categoryId,
            images: ["image1", "image2"],
            coverImage: "coverImage",
            manufacturer: "Test Manufacturer",
            barcode: "1234567890123",
            tags: ["tag1", "tag2"]
        )
        
        XCTAssertEqual(create.name, "Test Product")
        XCTAssertEqual(create.description, "Test product description")
        XCTAssertEqual(create.price, 100.00)
        XCTAssertEqual(create.unit, "kg")
        XCTAssertEqual(create.categoryId, categoryId)
        XCTAssertEqual(create.images, ["image1", "image2"])
        XCTAssertEqual(create.coverImage, "coverImage")
        XCTAssertEqual(create.manufacturer, "Test Manufacturer")
        XCTAssertEqual(create.barcode, "1234567890123")
        XCTAssertEqual(create.tags, ["tag1", "tag2"])
    }

    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let categoryId = UUID()
        let create = ProductRequest.Create(
            name: "Test Product",
            description: "Test product description",
            price: 100.00,
            unit: "kg",
            categoryId: categoryId,
            images: ["image1", "image2"],
            coverImage: "coverImage",
            manufacturer: "Test Manufacturer",
            barcode: "1234567890123",
            tags: ["tag1", "tag2"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(create)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Test Product")
        XCTAssertEqual(jsonObject?["description"] as? String, "Test product description")
        XCTAssertEqual(jsonObject?["price"] as? Double, 100.00)
        XCTAssertEqual(jsonObject?["unit"] as? String, "kg")
        XCTAssertEqual(jsonObject?["category_id"] as? String, categoryId.uuidString)
        XCTAssertEqual(jsonObject?["images"] as? [String], ["image1", "image2"])
        XCTAssertEqual(jsonObject?["cover_image"] as? String, "coverImage")
        XCTAssertEqual(jsonObject?["manufacturer"] as? String, "Test Manufacturer")
        XCTAssertEqual(jsonObject?["barcode"] as? String, "1234567890123")
        XCTAssertEqual(jsonObject?["tags"] as? [String], ["tag1", "tag2"])
    }

    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let categoryId = UUID()
        let json = """
        {
            "name": "Test Product",
            "description": "Test product description",
            "price": 100.00,
            "unit": "kg",
            "category_id": "\(categoryId.uuidString)",
            "images": ["image1", "image2"],
            "cover_image": "coverImage",
            "manufacturer": "Test Manufacturer",
            "barcode": "1234567890123",
            "tags": ["tag1", "tag2"]
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let create = try decoder.decode(ProductRequest.Create.self, from: data)
        
        XCTAssertEqual(create.name, "Test Product")
        XCTAssertEqual(create.description, "Test product description")
        XCTAssertEqual(create.price, 100.00)
        XCTAssertEqual(create.unit, "kg")
        XCTAssertEqual(create.categoryId, categoryId)
        XCTAssertEqual(create.images, ["image1", "image2"])
        XCTAssertEqual(create.coverImage, "coverImage")
        XCTAssertEqual(create.manufacturer, "Test Manufacturer")
        XCTAssertEqual(create.barcode, "1234567890123")
        XCTAssertEqual(create.tags, ["tag1", "tag2"])
    }

    // MARK: - Update Tests
    
    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let categoryId = UUID()
        let update = ProductRequest.Update(
            name: "Updated Product",
            description: "Updated product description",
            price: 150.00,
            unit: "liters",
            categoryId: categoryId,
            images: ["image3", "image4"],
            coverImage: "updatedCoverImage",
            manufacturer: "Updated Manufacturer",
            barcode: "0987654321098",
            tags: ["tag3", "tag4"]
        )
        
        XCTAssertEqual(update.name, "Updated Product")
        XCTAssertEqual(update.description, "Updated product description")
        XCTAssertEqual(update.price, 150.00)
        XCTAssertEqual(update.unit, "liters")
        XCTAssertEqual(update.categoryId, categoryId)
        XCTAssertEqual(update.images, ["image3", "image4"])
        XCTAssertEqual(update.coverImage, "updatedCoverImage")
        XCTAssertEqual(update.manufacturer, "Updated Manufacturer")
        XCTAssertEqual(update.barcode, "0987654321098")
        XCTAssertEqual(update.tags, ["tag3", "tag4"])
    }

    func testUpdateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let update = ProductRequest.Update(
            name: "Updated Product",
            description: "Updated product description",
            price: 150.00,
            unit: "liters",
            categoryId: UUID(),
            images: ["image3", "image4"],
            coverImage: "updatedCoverImage",
            manufacturer: "Updated Manufacturer",
            barcode: "0987654321098",
            tags: ["tag3", "tag4"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(update)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Updated Product")
        XCTAssertEqual(jsonObject?["description"] as? String, "Updated product description")
        XCTAssertEqual(jsonObject?["price"] as? Double, 150.00)
        XCTAssertEqual(jsonObject?["unit"] as? String, "liters")
        XCTAssertEqual(jsonObject?["category_id"] as? String, update.categoryId?.uuidString)
        XCTAssertEqual(jsonObject?["images"] as? [String], ["image3", "image4"])
        XCTAssertEqual(jsonObject?["cover_image"] as? String, "updatedCoverImage")
        XCTAssertEqual(jsonObject?["manufacturer"] as? String, "Updated Manufacturer")
        XCTAssertEqual(jsonObject?["barcode"] as? String, "0987654321098")
        XCTAssertEqual(jsonObject?["tags"] as? [String], ["tag3", "tag4"])
    }

    func testUpdateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let categoryId = UUID()
        let json = """
        {
            "name": "Updated Product",
            "description": "Updated product description",
            "price": 150.00,
            "unit": "liters",
            "category_id": "\(categoryId.uuidString)",
            "images": ["image3", "image4"],
            "cover_image": "updatedCoverImage",
            "manufacturer": "Updated Manufacturer",
            "barcode": "0987654321098",
            "tags": ["tag3", "tag4"]
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let update = try decoder.decode(ProductRequest.Update.self, from: data)
        
        XCTAssertEqual(update.name, "Updated Product")
        XCTAssertEqual(update.description, "Updated product description")
        XCTAssertEqual(update.price, 150.00)
        XCTAssertEqual(update.unit, "liters")
        XCTAssertEqual(update.categoryId, categoryId)
        XCTAssertEqual(update.images, ["image3", "image4"])
        XCTAssertEqual(update.coverImage, "updatedCoverImage")
        XCTAssertEqual(update.manufacturer, "Updated Manufacturer")
        XCTAssertEqual(update.barcode, "0987654321098")
        XCTAssertEqual(update.tags, ["tag3", "tag4"])
    }
    
    // MARK: - CreateVariant Tests
    
    func testCreateVariantInit_WithValidValues_ShouldReturnCorrectValues() {
        let dimensions = ProductDimension(length: 10,
                                          width: 5,
                                          height: 2,
                                          weight: 1,
                                          lengthUnit: "cm",
                                          widthUnit: "cm",
                                          heightUnit: "cm",
                                          weightUnit: "kg")
        let createVariant = ProductRequest.CreateVariant(
            name: "Test Variant",
            sku: "SKU-001",
            price: 150.00,
            description: "Test description",
            image: "image_url",
            color: "red",
            barcode: "1234567890123",
            dimensions: dimensions
        )
        
        XCTAssertEqual(createVariant.name, "Test Variant")
        XCTAssertEqual(createVariant.sku, "SKU-001")
        XCTAssertEqual(createVariant.price, 150.00)
        XCTAssertEqual(createVariant.description, "Test description")
        XCTAssertEqual(createVariant.image, "image_url")
        XCTAssertEqual(createVariant.color, "red")
        XCTAssertEqual(createVariant.barcode, "1234567890123")
        XCTAssertEqual(createVariant.dimensions?.length, 10)
        XCTAssertEqual(createVariant.dimensions?.width, 5)
        XCTAssertEqual(createVariant.dimensions?.height, 2)
        XCTAssertEqual(createVariant.dimensions?.weight, 1)
        XCTAssertEqual(createVariant.dimensions?.lengthUnit, "cm")
        XCTAssertEqual(createVariant.dimensions?.widthUnit, "cm")
        XCTAssertEqual(createVariant.dimensions?.heightUnit, "cm")
        XCTAssertEqual(createVariant.dimensions?.weightUnit, "kg")
        
    }

    func testCreateVariantEncode_WithValidInstance_ShouldReturnJSON() throws {
        let dimensions = ProductDimension(length: 10,
                                          width: 5,
                                          height: 2,
                                          weight: 1,
                                          lengthUnit: "cm",
                                          widthUnit: "cm",
                                          heightUnit: "cm",
                                          weightUnit: "kg")
        let createVariant = ProductRequest.CreateVariant(
            name: "Test Variant",
            sku: "SKU-001",
            price: 150.00,
            description: "Test description",
            image: "image_url",
            color: "red",
            barcode: "1234567890123",
            dimensions: dimensions
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(createVariant)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Test Variant")
        XCTAssertEqual(jsonObject?["sku"] as? String, "SKU-001")
        XCTAssertEqual(jsonObject?["price"] as? Double, 150.00)
        XCTAssertEqual(jsonObject?["description"] as? String, "Test description")
        XCTAssertEqual(jsonObject?["image"] as? String, "image_url")
        XCTAssertEqual(jsonObject?["color"] as? String, "red")
        XCTAssertEqual(jsonObject?["barcode"] as? String, "1234567890123")
        
        if let dimensionsDict = jsonObject?["dimensions"] as? [String: Any] {
            XCTAssertEqual(dimensionsDict["length"] as? Double, 10)
            XCTAssertEqual(dimensionsDict["width"] as? Double, 5)
            XCTAssertEqual(dimensionsDict["height"] as? Double, 2)
            XCTAssertEqual(dimensionsDict["weight"] as? Double, 1)
            XCTAssertEqual(dimensionsDict["length_unit"] as? String, "cm")
            XCTAssertEqual(dimensionsDict["width_unit"] as? String, "cm")
            XCTAssertEqual(dimensionsDict["height_unit"] as? String, "cm")
            XCTAssertEqual(dimensionsDict["weight_unit"] as? String, "kg")
        }
    }

    func testCreateVariantDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "name": "Test Variant",
            "sku": "SKU-001",
            "price": 150.00,
            "description": "Test description",
            "image": "image_url",
            "color": "red",
            "barcode": "1234567890123",
            "dimensions": {
                "length": 10,
                "width": 5,
                "height": 2,
                "weight": 1,
                "length_unit": "cm",
                "width_unit": "cm",
                "height_unit": "cm",
                "weight_unit": "kg"
            }
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let createVariant = try decoder.decode(ProductRequest.CreateVariant.self, from: data)
        
        XCTAssertEqual(createVariant.name, "Test Variant")
        XCTAssertEqual(createVariant.sku, "SKU-001")
        XCTAssertEqual(createVariant.price, 150.00)
        XCTAssertEqual(createVariant.description, "Test description")
        XCTAssertEqual(createVariant.image, "image_url")
        XCTAssertEqual(createVariant.color, "red")
        XCTAssertEqual(createVariant.barcode, "1234567890123")
        
        XCTAssertEqual(createVariant.dimensions?.length, 10)
        XCTAssertEqual(createVariant.dimensions?.weight, 1)
        XCTAssertEqual(createVariant.dimensions?.width, 5)
        XCTAssertEqual(createVariant.dimensions?.height, 2)
        XCTAssertEqual(createVariant.dimensions?.lengthUnit, "cm")
        XCTAssertEqual(createVariant.dimensions?.weightUnit, "kg")
        XCTAssertEqual(createVariant.dimensions?.widthUnit, "cm")
        XCTAssertEqual(createVariant.dimensions?.heightUnit, "cm")
    }
    
    // MARK: - UpdateVariant Tests
    
    func testUpdateVariantInit_WithValidValues_ShouldReturnCorrectValues() {
        let dimensions = ProductDimension(length: 15,
                                          width: 10,
                                          height: 5,
                                          weight: 2,
                                          lengthUnit: "cm",
                                          widthUnit: "cm",
                                          heightUnit: "cm",
                                          weightUnit: "kg")
        let updateVariant = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            sku: "SKU-002",
            price: 200.00,
            description: "Updated description",
            image: "updated_image_url",
            color: "blue",
            barcode: "0987654321098",
            dimensions: dimensions
        )
        
        XCTAssertEqual(updateVariant.name, "Updated Variant")
        XCTAssertEqual(updateVariant.sku, "SKU-002")
        XCTAssertEqual(updateVariant.price, 200.00)
        XCTAssertEqual(updateVariant.description, "Updated description")
        XCTAssertEqual(updateVariant.image, "updated_image_url")
        XCTAssertEqual(updateVariant.color, "blue")
        XCTAssertEqual(updateVariant.barcode, "0987654321098")
        XCTAssertEqual(updateVariant.dimensions?.length, 15)
        XCTAssertEqual(updateVariant.dimensions?.weight, 2)
        XCTAssertEqual(updateVariant.dimensions?.width, 10)
        XCTAssertEqual(updateVariant.dimensions?.height, 5)
        XCTAssertEqual(updateVariant.dimensions?.lengthUnit, "cm")
        XCTAssertEqual(updateVariant.dimensions?.weightUnit, "kg")
        XCTAssertEqual(updateVariant.dimensions?.widthUnit, "cm")
        XCTAssertEqual(updateVariant.dimensions?.heightUnit, "cm")
    }

    func testUpdateVariantEncode_WithValidInstance_ShouldReturnJSON() throws {
        let dimensions = ProductDimension(length: 15,
                                          width: 10,
                                          height: 5,
                                          weight: 2,
                                          lengthUnit: "cm",
                                          widthUnit: "cm",
                                          heightUnit: "cm",
                                          weightUnit: "kg")
        let updateVariant = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            sku: "SKU-002",
            price: 200.00,
            description: "Updated description",
            image: "updated_image_url",
            color: "blue",
            barcode: "0987654321098",
            dimensions: dimensions
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(updateVariant)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Updated Variant")
        XCTAssertEqual(jsonObject?["sku"] as? String, "SKU-002")
        XCTAssertEqual(jsonObject?["price"] as? Double, 200.00)
        XCTAssertEqual(jsonObject?["description"] as? String, "Updated description")
        XCTAssertEqual(jsonObject?["image"] as? String, "updated_image_url")
        XCTAssertEqual(jsonObject?["color"] as? String, "blue")
        XCTAssertEqual(jsonObject?["barcode"] as? String, "0987654321098")
        
        if let dimensionsDict = jsonObject?["dimensions"] as? [String: Any] {
            XCTAssertEqual(dimensionsDict["length"] as? Double, 15)
            XCTAssertEqual(dimensionsDict["weight"] as? Double, 2)
            XCTAssertEqual(dimensionsDict["width"] as? Double, 10)
            XCTAssertEqual(dimensionsDict["height"] as? Double, 5)
            XCTAssertEqual(dimensionsDict["length_unit"] as? String, "cm")
            XCTAssertEqual(dimensionsDict["weight_unit"] as? String, "kg")
            XCTAssertEqual(dimensionsDict["width_unit"] as? String, "cm")
            XCTAssertEqual(dimensionsDict["height_unit"] as? String, "cm")
        }
    }

    func testUpdateVariantDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "name": "Updated Variant",
            "sku": "SKU-002",
            "price": 200.00,
            "description": "Updated description",
            "image": "updated_image_url",
            "color": "blue",
            "barcode": "0987654321098",
            "dimensions": {
                "length": 15,
                "width": 10,
                "height": 5,
                "weight": 2,
                "length_unit": "cm",
                "width_unit": "cm",
                "height_unit": "cm",
                "weight_unit": "kg"
            }
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let updateVariant = try decoder.decode(ProductRequest.UpdateVariant.self, from: data)
        
        XCTAssertEqual(updateVariant.name, "Updated Variant")
        XCTAssertEqual(updateVariant.sku, "SKU-002")
        XCTAssertEqual(updateVariant.price, 200.00)
        XCTAssertEqual(updateVariant.description, "Updated description")
        XCTAssertEqual(updateVariant.image, "updated_image_url")
        XCTAssertEqual(updateVariant.color, "blue")
        XCTAssertEqual(updateVariant.barcode, "0987654321098")
        
        XCTAssertEqual(updateVariant.dimensions?.length, 15)
        XCTAssertEqual(updateVariant.dimensions?.weight, 2)
        XCTAssertEqual(updateVariant.dimensions?.width, 10)
        XCTAssertEqual(updateVariant.dimensions?.height, 5)
        XCTAssertEqual(updateVariant.dimensions?.lengthUnit, "cm")
        XCTAssertEqual(updateVariant.dimensions?.weightUnit, "kg")
        XCTAssertEqual(updateVariant.dimensions?.widthUnit, "cm")
        XCTAssertEqual(updateVariant.dimensions?.heightUnit, "cm")
    }
    
}
