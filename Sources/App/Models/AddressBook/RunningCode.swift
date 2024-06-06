import Foundation

// ex. .init(prefix: "C") : "C00001"
@propertyWrapper
struct RunningCode {
    private var value: Int
    private let prefix: String

    init(prefix: String,
         runningNumber: Int = 1) {
        self.prefix = prefix
        self.value = max(runningNumber,1)
    }
    
    var wrappedValue: String {
        get {             
            let formattedNumber = Self.formatNumber(value)
            return prefix + formattedNumber
         }
        set {
            // You can handle setting the value if needed
            // For simplicity, we don't support setting the value explicitly in this example
            // You may need to implement this based on your use case
        }
    }    
    
    static func formatNumber(_ number: Int) -> String {
        // Convert the number to a string
        let numberString = String(number)
        
        // Define the desired length for the number part
        let desiredLength = 5
        
        // Pad the number string with leading zeros
        let paddedNumberString = String(repeating: "0", count: max(0, desiredLength - numberString.count)) + numberString        
        
        return paddedNumberString
    }
}

