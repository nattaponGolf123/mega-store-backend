@testable import App
import XCTVapor

final class RunningCodeTests: XCTestCase {
    
    func testRunningCodeWrapper_WithPrefix_ShouldAddPrefixAndFormatNumber() {
        let code = RunningCode(prefix: "C")
        XCTAssertEqual(code.wrappedValue, "C00001")
    }
    
    func testRunningCodeWrapper_WithDifferentPrefix_ShouldAddDifferentPrefixAndFormatNumber() {
        let code = RunningCode(prefix: "D")
        XCTAssertEqual(code.wrappedValue, "D00001")
    }
    
    func testRunningCodeWrapper_WithCustomStartingNumber_ShouldFormatNumber() {
        let code = RunningCode(prefix: "C", runningNumber: 123)
        XCTAssertEqual(code.wrappedValue, "C00123")
        
        let code1 = RunningCode(prefix: "C", runningNumber: 1)
        XCTAssertEqual(code1.wrappedValue, "C00001")
        
        let code2 = RunningCode(prefix: "C", runningNumber: 0)
        XCTAssertEqual(code2.wrappedValue, "C00001")
        
        let code3 = RunningCode(prefix: "C", runningNumber: -1)
        XCTAssertEqual(code3.wrappedValue, "C00001")
        
        let code4 = RunningCode(prefix: "C", runningNumber: -123)
        XCTAssertEqual(code4.wrappedValue, "C00001")
        
        let code5 = RunningCode(prefix: "C", runningNumber: 2)
        XCTAssertEqual(code5.wrappedValue, "C00002")
            
        let code6 = RunningCode(prefix: "C", runningNumber: 3)
        XCTAssertEqual(code6.wrappedValue, "C00003")
    }
    
    // test with 6 digi
    func testRunningCodeWrapper_WithCustomStartingNumberOver9999_ShouldFormatNumber() {
        let code = RunningCode(prefix: "C", runningNumber: 12345)
        XCTAssertEqual(code.wrappedValue, "C12345")
    }
}
