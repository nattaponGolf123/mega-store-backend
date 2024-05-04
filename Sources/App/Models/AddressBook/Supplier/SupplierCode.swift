import Foundation

 struct SupplierCode {
        @RunningCode(prefix: "S")
        var code: String 

        init(number: Int) {
            code = "\(number)"
        }
    }