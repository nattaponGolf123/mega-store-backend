import Foundation

struct ContactCode {
    @RunningCode(prefix: "C")
    var code: String
    
    init(number: Int) {
        _code = RunningCode(prefix: "C", runningNumber: number)
    }
    
    static func getNumber(from code: String) -> Int? {
        
       //remove all alphabel from code
        let number = code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let number = Int(number) {
            return number
        }
        
        return nil
        
    }
}
