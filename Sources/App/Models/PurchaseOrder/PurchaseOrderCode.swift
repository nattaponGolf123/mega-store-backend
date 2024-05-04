 import Foundation

 struct PurchaseOrderCode {
        @RunningCode(prefix: "PO")
        var code: String 

        init(number: Int) {
            code = "\(number)"
        }
    }