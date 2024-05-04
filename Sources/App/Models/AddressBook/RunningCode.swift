import Foundation

// ex. .init(prefix: "C") : "C00001"
@propertyWrapper
struct RunningCode {
    private var value: String
    private let prefix: String
    
    init(prefix: String,
         runningNumber: Int = 1) {
        self.prefix = prefix
        self.value = prefix + String(format: "%05d", runningNumber)        
    }
    
    var wrappedValue: String {
        get { value }
        set {
            if isValidCustomerCode(newValue) {
                value = newValue
            } else {
                print("Invalid customer code format")
            }
        }
    }
    
    private func isValidCustomerCode(_ code: String) -> Bool {
        let pattern = "\(prefix)[0-9]{5}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: code.utf16.count)
        return regex.firstMatch(in: code, options: [], range: range) != nil
    }
}

