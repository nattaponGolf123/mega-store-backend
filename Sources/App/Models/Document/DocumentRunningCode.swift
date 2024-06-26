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
