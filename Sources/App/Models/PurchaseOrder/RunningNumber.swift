//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation

@propertyWrapper
struct RunningNumber {
    let prefix: String
    let year: Int
    let currentValue: Int
    
    var wrappedValue: String {
        get {
            let formattedYear = String(format: "%04d", year)
            let formattedNumber = String(format: "%05d", currentValue)
            return "\(prefix)-\(formattedYear)-\(formattedNumber)"
        }
        mutating set {
            // You can handle setting the value if needed
            // For simplicity, we don't support setting the value explicitly in this example
            // You may need to implement this based on your use case
        }
    }
    
    init(prefix: String,
         year: Date = .init(),
         initialValue: Int = 1) {
        self.prefix = prefix
        self.year = Calendar.current.component(.year,
                                               from: year)
        self.currentValue = initialValue
    }
}


// Example usage
//struct PurchaseOrder {
//    @RunningNumber(prefix: "PO")
//    var runningNumber: String
//}
//
//var order = PurchaseOrder()
//print(order.runningNumber) // Output: PO-2024-00001
