import Foundation

@propertyWrapper
struct CustomerCode {
    private var value: String

    init(value: Int) {
        self.value = String(value)
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
        let regex = #"^C\d{4}\d$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: code)
    }
}