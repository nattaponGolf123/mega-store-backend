@testable import App
import XCTVapor

final class VatTests: XCTestCase {

    func testInit_WithTotalAmountIncludeVat_ShouldCalculateAmountBeforeAndAfter() {
        // Given
        let totalAmountIncludeVat: Double = 100.0
        let rate: Double = 0.07        
        
        // When
        let vat = Vat(totalAmountIncludeVat: totalAmountIncludeVat, rate: rate)
        
        // Then
        XCTAssertEqual(vat.amount, 6.5420560748, accuracy: 0.0001)
        XCTAssertEqual(vat.rate, rate, accuracy: 0.0001)
        XCTAssertEqual(vat.amountBefore, 93.4579439252, accuracy: 0.0001)
        XCTAssertEqual(vat.amountAfter, 100, accuracy: 0.0001)
    }

    func testInit_WithTotalAmountExcludeVat_ShouldCalculateAmountBeforeAndAfter() {
        // Given
        let totalAmountExcludeVat: Double = 100.0
        let rate: Double = 0.07
        
        // When
        let vat = Vat(totalAmountExcludeVat: totalAmountExcludeVat, rate: rate)
        
        // Then
        XCTAssertEqual(vat.amount, 7, accuracy: 0.0001)
        XCTAssertEqual(vat.rate, rate, accuracy: 0.0001)
        XCTAssertEqual(vat.amountBefore, 100, accuracy: 0.0001)
        XCTAssertEqual(vat.amountAfter, 107, accuracy: 0.0001)
    }

    func testDecode_WithValidJson_ShouldReturnVatInstance() throws {
        // Given
        let json = """
        {
            "amount": 7.0,
            "rate": 0.07,
            "amount_before": 100.0,
            "amount_after": 107.0
        }
        """.data(using: .utf8)!
        
        // When
        let vat = try JSONDecoder().decode(Vat.self, from: json)
        
        // Then
        XCTAssertEqual(vat.amount, 7.0, accuracy: 0.0001)
        XCTAssertEqual(vat.rate, 0.07, accuracy: 0.0001)
        XCTAssertEqual(vat.amountBefore, 100.0, accuracy: 0.0001)
        XCTAssertEqual(vat.amountAfter, 107.0, accuracy: 0.0001)
    }

    func testEncode_WithVatInstance_ShouldReturnValidJson() throws {
        // Given
        let vat = Vat(totalAmountExcludeVat: 100.0, rate: 0.07)
        
        // When
        let jsonData = try JSONEncoder().encode(vat)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        
        // Then
        let expectedJson: [String: Any] = [
            "amount": 7.0,
            "rate": 0.07,
            "amount_before": 100.0,
            "amount_after": 107.0
        ]
        
        XCTAssertEqual(jsonObject?["amount"] as! Double, expectedJson["amount"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["rate"] as! Double, expectedJson["rate"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["amount_before"] as! Double, expectedJson["amount_before"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["amount_after"] as! Double, expectedJson["amount_after"] as! Double, accuracy: 0.0001)
    }
}

extension VatTests {
    struct Stub {
        static var sampleVat: Vat {
            return Vat(totalAmountExcludeVat: 100.0, rate: 0.07)
        }
    }
}
