import Foundation

@propertyWrapper
struct SupplierCode {
    private var value: String

    init(value: Int) {
        self.value = String(value)
    }
    
    var wrappedValue: String {
        get { value }
        set {
            if isValidSupplierCode(newValue) {
                value = newValue
            } else {
                print("Invalid supplier code format")
            }
        }
    }
    
    private func isValidSupplierCode(_ code: String) -> Bool {
        let regex = #"^S\d{4}\d$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: code)
    }
}

