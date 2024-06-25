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
    private var _year: Int?
    private var _month: Int?
    private var _value: Int?
    var calendarIdentifier: Calendar.Identifier
    
    var year: Int? {
        get { _year }
        set {
            if let newYear = newValue {
                _year = adjustYearForCalendar(year: newYear, calendar: calendarIdentifier)
                updateFormattedValue()
            }
        }
    }

    var month: Int? {
        get { _month }
        set {
            _month = newValue
            updateFormattedValue()
        }
    }

    var value: Int? {
        get { _value }
        set {
            _value = newValue
            updateFormattedValue()
        }
    }
    
    var wrappedValue: String = "Incomplete Data"
    
    private mutating func updateFormattedValue() {
        guard let year = _year, let month = _month, let value = _value else {
            wrappedValue = "Incomplete Data"
            return
        }
        let formattedYear = String(format: "%02d", year % 100) // Get the last two digits of the year
        let formattedMonth = String(format: "%02d", month)
        let formattedNumber = String(format: "%04d", value)
        wrappedValue = "\(prefix)-\(formattedYear)\(formattedMonth)-\(formattedNumber)"
    }
    
    init(prefix: String, calendarIdentifier: Calendar.Identifier = .gregorian) {
        self.prefix = prefix
        self.calendarIdentifier = calendarIdentifier
    }
    
    private func adjustYearForCalendar(year: Int, 
                                       calendar: Calendar.Identifier) -> Int {
        switch calendar {
        case .buddhist:
            return year + 543 // adjustment for Buddhist calendar
        default:
            return year // No adjustment needed for Gregorian
        }
    }
}

//
//@propertyWrapper
//struct DocumentRunningCode {
//    let prefix: String
//    let year: Int
//    let month: Int
//    let value: Int
//    
//    var wrappedValue: String {
//        get {
//            let formattedYear = String(format: "%02d", year % 100) // Get the last two digits of the year
//            let formattedMonth = String(format: "%02d", month)
//            let formattedNumber = String(format: "%04d", value)
//            return "\(prefix)-\(formattedYear)\(formattedMonth)-\(formattedNumber)"
//        }
//        mutating set {
//            // You can handle setting the value if needed
//            // For simplicity, we don't support setting the value explicitly in this example
//            // You may need to implement this based on your use case
//        }
//    }
//    
//    init(prefix: String,
//         gregorianYear: Int, // gregorian year 20xx
//         month: Int, // month 1 - 12
//         runningNumber: Int = 1,
//         calendarIdentifier: Calendar.Identifier) {
//        self.prefix = prefix
//        
//        switch calendarIdentifier {
//        case .buddhist:
//            self.year = gregorianYear + 543 // adjustment
//            self.month = month
//            self.value = runningNumber
//            
//        default:
//            self.year = gregorianYear
//            self.month = month
//            self.value = runningNumber
//        }
//    }
//}

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
