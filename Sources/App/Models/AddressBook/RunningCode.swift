import Foundation

// ex. .init(prefix: "C") : "C00001"
@propertyWrapper
struct RunningCode {
    private var value: Int
    private let prefix: String

    init(prefix: String,
         runningNumber: Int = 1) {
        self.prefix = prefix
        self.value = runningNumber
    }
    
    var wrappedValue: String {
        get {             
            let formattedNumber = String(format: "%05d", value)
            return prefix + formattedNumber
         }
        set {
            // You can handle setting the value if needed
            // For simplicity, we don't support setting the value explicitly in this example
            // You may need to implement this based on your use case
        }
    }    
}

