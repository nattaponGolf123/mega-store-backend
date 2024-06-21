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
        let expectedAmountBefore = totalAmountIncludeVat / (1 + rate)
        let expectedAmountAfter = totalAmountIncludeVat

        XCTAssertEqual(vat.amount, totalAmountIncludeVat, accuracy: 0.0001)
        XCTAssertEqual(vat.rate, rate, accuracy: 0.0001)
        XCTAssertEqual(vat.amountBefore, expectedAmountBefore, accuracy: 0.0001)
        XCTAssertEqual(vat.amountAfter, expectedAmountAfter, accuracy: 0.0001)
    }

    func testInit_WithTotalAmountExcludeVat_ShouldCalculateAmountBeforeAndAfter() {
        // Given
        let totalAmountExcludeVat: Double = 100.0
        let rate: Double = 0.07
        
        // When
        let vat = Vat(totalAmountExcludeVat: totalAmountExcludeVat, rate: rate)
        
        // Then
        let expectedAmountBefore = totalAmountExcludeVat
        let expectedAmountAfter = totalAmountExcludeVat * (1 + rate)

        XCTAssertEqual(vat.amount, totalAmountExcludeVat * rate, accuracy: 0.0001)
        XCTAssertEqual(vat.rate, rate, accuracy: 0.0001)
        XCTAssertEqual(vat.amountBefore, expectedAmountBefore, accuracy: 0.0001)
        XCTAssertEqual(vat.amountAfter, expectedAmountAfter, accuracy: 0.0001)
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

/*

 struct Vat: Content {
     
     let amount: Double // vat amount
     let rate: Double // vat rate
     let amountBefore: Double // total amount before vat
     let amountAfter: Double // total amount include vat
     
     // include vat
     init(totalAmountIncludeVat: Double,
          rate: Double = 0.07) {
         self.amount = totalAmountIncludeVat
         self.rate = rate
         self.amountBefore = totalAmountIncludeVat / (1 + rate)
         self.amountAfter = totalAmountIncludeVat
     }
     
     // exclude vat
     init(totalAmountExcludeVat: Double,
          rate: Double = 0.07) {
         self.amount = totalAmountExcludeVat * rate
         self.rate = rate
         self.amountBefore = totalAmountExcludeVat
         self.amountAfter = totalAmountExcludeVat * (1 + rate)
     }
     
     //decode
     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         self.amount = try container.decode(Double.self,
                                            forKey: .amount)
         self.rate = try container.decode(Double.self,
                                          forKey: .rate)
         self.amountBefore = try container.decode(Double.self,
                                                     forKey: .amountBefore)
         self.amountAfter = try container.decode(Double.self,
                                                    forKey: .amountAfter)
     }
     
     //encode
     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(amount, forKey: .amount)
         try container.encode(rate, forKey: .rate)
         try container.encode(amountBefore, forKey: .amountBefore)
         try container.encode(amountAfter, forKey: .amountAfter)
     }
     
     enum CodingKeys: String, CodingKey {
         case amount
         case rate
         case amountBefore = "amount_before"
         case amountAfter = "amount_after"
     }
     
 }

*/
