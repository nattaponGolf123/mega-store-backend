@testable import App
import XCTVapor

final class ContactCodeTests: XCTestCase {
    
    // Test Initialization
    func testInit_WithValidNumber_ShouldSetCodeWithPrefix() {
        let contactCode = ContactCode(number: 123)
        XCTAssertEqual(contactCode.code, "C00123")
    }
    
    // Test static method getNumber(from:)
    func testGetNumber_WithValidCode_ShouldReturnNumber() {
        let code = "C123"
        let number = ContactCode.getNumber(from: code)
        XCTAssertEqual(number, 123)
    }
    
    func testGetNumber_WithInvalidCode_ShouldReturnNil() {
        let code = "123"
        let number = ContactCode.getNumber(from: code)
        XCTAssertNotNil(number)
    }
    
    func testGetNumber_WithNonNumericCode_ShouldReturnNil() {
        let code = "Cabc"
        let number = ContactCode.getNumber(from: code)
        XCTAssertNil(number)
    }
    
    func testCodeProperty_WithPrefixBehavior_ShouldAddPrefix() {
        let contactCode = ContactCode(number: 456)
        XCTAssertEqual(contactCode.code, "C00456")
    }
    
}
