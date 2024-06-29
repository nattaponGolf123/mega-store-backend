@testable import App
import XCTVapor

class DocumentRunningCodeTests: XCTestCase {
    
    func testInit_WithPrefixAndDefaultCalendar_ShouldInitializeCorrectly() {
        // Given
        let prefix = "DOC"
        
        // When
        let documentRunningCode = DocumentRunningCode(prefix: prefix)
        
        // Then
        XCTAssertEqual(documentRunningCode.prefix, prefix)
        XCTAssertEqual(documentRunningCode.calendarIdentifier, .gregorian)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testInit_WithPrefixAndBuddhistCalendar_ShouldInitializeCorrectly() {
        // Given
        let prefix = "DOC"
        
        // When
        let documentRunningCode = DocumentRunningCode(prefix: prefix, calendarIdentifier: .buddhist)
        
        // Then
        XCTAssertEqual(documentRunningCode.prefix, prefix)
        XCTAssertEqual(documentRunningCode.calendarIdentifier, .buddhist)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testYear_WithValidYearAndBuddhistCalendar_ShouldAdjustAndReturnFormattedValue() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .buddhist)
        
        // When
        documentRunningCode.year = 2023
        
        // Then
        XCTAssertEqual(documentRunningCode.year, 2566)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testYear_WithValidYearAndGregorianCalendar_ShouldNotAdjustYearAndReturnFormattedValue() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .gregorian)
        
        // When
        documentRunningCode.year = 2023
        
        // Then
        XCTAssertEqual(documentRunningCode.year, 2023)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testMonth_WithValidMonth_ShouldReturnFormattedValue() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC")
        
        // When
        documentRunningCode.month = 6
        
        // Then
        XCTAssertEqual(documentRunningCode.month, 6)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testValue_WithValidValue_ShouldReturnFormattedValue() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC")
        
        // When
        documentRunningCode.value = 1234
        
        // Then
        XCTAssertEqual(documentRunningCode.value, 1234)
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
    
    func testWrappedValue_WithCompleteDataAndGregorianCalendar_ShouldReturnFormattedString() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .gregorian)
        documentRunningCode.year = 2023
        documentRunningCode.month = 6
        documentRunningCode.value = 1234
        
        // Then
        XCTAssertEqual(documentRunningCode.wrappedValue, "DOC-2306-1234")
    }
    
    func testWrappedValue_WithCompleteDataAndBuddhistCalendar_ShouldReturnFormattedString() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .buddhist)
        documentRunningCode.year = 2023
        documentRunningCode.month = 6
        documentRunningCode.value = 1234
        
        // Then
        XCTAssertEqual(documentRunningCode.wrappedValue, "DOC-6606-1234")
    }
    
    func testWrappedValue_WithIncompleteData_ShouldReturnIncompleteData() {
        // Given
        var documentRunningCode = DocumentRunningCode(prefix: "DOC")
        documentRunningCode.year = 2023
        documentRunningCode.month = 6
        
        // Then
        XCTAssertEqual(documentRunningCode.wrappedValue, "Incomplete Data")
    }
}

// Extension to provide stub data
extension DocumentRunningCodeTests {
    struct Stub {
        static var completeDataGregorian: DocumentRunningCode {
            var doc = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .gregorian)
            doc.year = 2023
            doc.month = 6
            doc.value = 1234
            return doc
        }
        
        static var completeDataBuddhist: DocumentRunningCode {
            var doc = DocumentRunningCode(prefix: "DOC", calendarIdentifier: .buddhist)
            doc.year = 2023
            doc.month = 6
            doc.value = 1234
            return doc
        }
        
        static var incompleteData: DocumentRunningCode {
            var doc = DocumentRunningCode(prefix: "DOC")
            doc.year = 2023
            doc.month = 6
            return doc
        }
    }
}
