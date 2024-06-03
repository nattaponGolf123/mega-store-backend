@testable import App
import XCTVapor

final class DocumentRunningCodeTests: XCTestCase {
    
    func testDocumentRunningCode_WithBuddhist() {
        // Create a date formatter to parse specific dates for testing
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .buddhist)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Test with specific date: 2567-05-01 (Buddhist calendar)
        let testDate1 = dateFormatter.date(from: "2567-05-01")!
        let documentCode1 = DocumentRunningCode(prefix: "PO", year: testDate1, runningNumber: 1,calendarIdentifier: .buddhist)
        XCTAssertEqual(documentCode1.wrappedValue, "PO-6705-0001")
        
        // Test with different running number
        let documentCode2 = DocumentRunningCode(prefix: "PO", year: testDate1, runningNumber: 123,calendarIdentifier: .buddhist)
        XCTAssertEqual(documentCode2.wrappedValue, "PO-6705-0123")
        
        // Test with a different month
        let testDate2 = dateFormatter.date(from: "2567-11-01")!
        let documentCode3 = DocumentRunningCode(prefix: "PO", year: testDate2, runningNumber: 1,calendarIdentifier: .buddhist)
        XCTAssertEqual(documentCode3.wrappedValue, "PO-6711-0001")
        
        // Test with another year
        let testDate3 = dateFormatter.date(from: "2568-03-01")!
        let documentCode4 = DocumentRunningCode(prefix: "PO", year: testDate3, runningNumber: 1,calendarIdentifier: .buddhist)
        XCTAssertEqual(documentCode4.wrappedValue, "PO-6803-0001")
    }
    
    func testDocumentRunningCode_WithGregorian() {
        // Create a date formatter to parse specific dates for testing
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Test with specific date: 2024-05-01 (Gregorian calendar)
        let testDate1 = dateFormatter.date(from: "2024-05-01")!
        let documentCode1 = DocumentRunningCode(prefix: "PO", year: testDate1, runningNumber: 1,calendarIdentifier: .gregorian)
        XCTAssertEqual(documentCode1.wrappedValue, "PO-6705-0001")
        
        // Test with different running number
        let documentCode2 = DocumentRunningCode(prefix: "PO", year: testDate1, runningNumber: 123,calendarIdentifier: .gregorian)
        XCTAssertEqual(documentCode2.wrappedValue, "PO-6705-0123")
        
        // Test with a different month
        let testDate2 = dateFormatter.date(from: "2024-11-01")!
        let documentCode3 = DocumentRunningCode(prefix: "PO", year: testDate2, runningNumber: 1,calendarIdentifier: .gregorian)
        XCTAssertEqual(documentCode3.wrappedValue, "PO-6711-0001")
        
        // Test with another year
        let testDate3 = dateFormatter.date(from: "2025-03-01")!
        let documentCode4 = DocumentRunningCode(prefix: "PO", year: testDate3, runningNumber: 1,calendarIdentifier: .gregorian)
        XCTAssertEqual(documentCode4.wrappedValue, "PO-6803-0001")
    }
    
}
