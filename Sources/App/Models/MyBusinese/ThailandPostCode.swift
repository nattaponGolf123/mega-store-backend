import Foundation

@propertyWrapper
struct ThailandPostCode {
    private var value: String = ""
    
    var wrappedValue: String {
        get { value }
        set {
            if isValidPostCode(newValue) {
                value = newValue
            } else {
                print("Invalid Thailand post code format")
            }
        }
    }
    
    init(wrappedValue: String) {
        if isValidPostCode(wrappedValue) {
            self.value = wrappedValue
        } else {
            print("Invalid Thailand post code format")
            self.value = ""
        }
    }
    
    private func isValidPostCode(_ postCode: String) -> Bool {
        // Add your validation logic here
        // For example, you can check if the post code matches the Thailand post code format
        // You can use regular expressions or any other validation method
        
        // Example validation: 5 digits
        let regex = #"^\d{5}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: postCode)
    }
}
