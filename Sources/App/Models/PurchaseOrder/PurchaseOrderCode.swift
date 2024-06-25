import Foundation

struct PurchaseOrderCode {
    @DocumentRunningCode(prefix: "PO")
    var code: String
    
    init(gregorianYear: Int,
         month: Int,
         number: Int) {
        _code.year = gregorianYear
        _code.month = month
        _code.value = number
    }
}
