//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation

@propertyWrapper
struct DocumentRunningCode {
    let prefix: String
    let year: Int
    let month: Int
    let value: Int
    
    var wrappedValue: String {
        get {
            let formattedYear = String(format: "%02d", year % 100) // Get the last two digits of the year
            let formattedMonth = String(format: "%02d", month)
            let formattedNumber = String(format: "%04d", value)
            return "\(prefix)-\(formattedYear)\(formattedMonth)-\(formattedNumber)"
        }
        mutating set {
            // You can handle setting the value if needed
            // For simplicity, we don't support setting the value explicitly in this example
            // You may need to implement this based on your use case
        }
    }
    
    init(prefix: String,
         year: Date = .init(),
         runningNumber: Int = 1,
         calendarIdentifier: Calendar.Identifier) {
        self.prefix = prefix
        switch calendarIdentifier {
            case .buddhist:
                let calendar = Calendar(identifier: calendarIdentifier)
                self.year = calendar.component(.year, from: year)
                self.month = calendar.component(.month, from: year)
                self.value = runningNumber
            case .gregorian:
                let calendar = Calendar(identifier: calendarIdentifier)
                self.year = calendar.component(.year, from: year) + 543 // adjustment
                self.month = calendar.component(.month, from: year)
                self.value = runningNumber
            default:
                let calendar = Calendar(identifier: calendarIdentifier)
                self.year = calendar.component(.year, from: year)
                self.month = calendar.component(.month, from: year)
                self.value = runningNumber
        }        
    }
}

//DocumentRunningCode.year = Date()

// Example usage
//struct PurchaseOrder {
//    @RunningNumber(prefix: "PO")
//    var runningNumber: String
//}
//
//var order = PurchaseOrder()
//print(order.runningNumber) // Output: PO-2024-00001

/*
@propertyWrapper
struct RunningCode {
    private var value: Int
    private let prefix: String

    init(prefix: String,
         runningNumber: Int = 1) {
        self.prefix = prefix
        self.value = prefix + String(format: "%05d", runningNumber)        
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
*/
