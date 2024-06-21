@testable import App
import XCTVapor

final class TaxWithholdingTests: XCTestCase {

    func testInit_WithTotalAmount_ShouldCalculateAmountBeforeAndAfter() {
        // Given
        let totalAmount: Double = 100.0
        let rate: Double = 0.03
        
        // When
        let taxWithholding = TaxWithholding(totalAmount: totalAmount, rate: rate)
        
        // Then
        XCTAssertEqual(taxWithholding.amount, 3, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.rate, rate, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.amountBefore, 100, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.amountAfter, 97, accuracy: 0.0001)
    }

    func testDecode_WithValidJson_ShouldReturnTaxWithholdingInstance() throws {
        // Given
        let json = """
        {
            "amount": 3.0,
            "rate": 0.03,
            "amount_before": 100.0,
            "amount_after": 97.0
        }
        """.data(using: .utf8)!
        
        // When
        let taxWithholding = try JSONDecoder().decode(TaxWithholding.self, from: json)
        
        // Then
        XCTAssertEqual(taxWithholding.amount, 3.0, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.rate, 0.03, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.amountBefore, 100.0, accuracy: 0.0001)
        XCTAssertEqual(taxWithholding.amountAfter, 97.0, accuracy: 0.0001)
    }

    func testEncode_WithTaxWithholdingInstance_ShouldReturnValidJson() throws {
        // Given
        let taxWithholding = TaxWithholding(totalAmount: 100.0, rate: 0.03)
        
        // When
        let jsonData = try JSONEncoder().encode(taxWithholding)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        
        // Then
        let expectedJson: [String: Any] = [
            "amount": 3.0,
            "rate": 0.03,
            "amount_before": 100.0,
            "amount_after": 97.0
        ]
        
        XCTAssertEqual(jsonObject?["amount"] as! Double, expectedJson["amount"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["rate"] as! Double, expectedJson["rate"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["amount_before"] as! Double, expectedJson["amount_before"] as! Double, accuracy: 0.0001)
        XCTAssertEqual(jsonObject?["amount_after"] as! Double, expectedJson["amount_after"] as! Double, accuracy: 0.0001)
    }
}

extension TaxWithholdingTests {
    struct Stub {
        static var sampleTaxWithholding: TaxWithholding {
            return TaxWithholding(totalAmount: 100.0, rate: 0.03)
        }
    }
}
