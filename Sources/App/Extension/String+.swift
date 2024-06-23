//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/6/2567 BE.
//

import Foundation

extension String {
    
    enum StringError: Error {
        case errorOnConvertion
    }
    
    // replace "+" with ""
    func replace(_ target: String,
                 withString: String) -> String{
        return self.replacingOccurrences(of: target,
                                         with: withString, 
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }
    
    func toDate(_ byDateFormat: String,
                timezone: TimeZone? = nil,
                locale: Locale? = nil,
                calendar: Calendar? = nil) -> Date? {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = byDateFormat
        dateFormatter.timeZone = timezone ?? TimeZone.current //TimeZone(identifier: "UTC")
        dateFormatter.locale = locale ?? Locale.current //Locale(identifier: "en")
        dateFormatter.calendar = calendar ?? Calendar(identifier: .gregorian)
        return dateFormatter.date(from: self)
    }
}

extension String {
    
    func tryToBool() throws -> Bool {
        guard
            let bool = self.toBool()
        else {
            throw StringError.errorOnConvertion
        }
        
        return bool
    }
    
    func toBool() -> Bool? {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func toBoolValue() -> Bool {
        return self.toBool() ?? false
    }

}


extension String {
    // convert string "0.0000" to double type
    var toDouble: Double? {
        let text = self.replace(",",
                               withString: "")
        return Double(text)
    }
    
    var toInt: Int? {
        return Int(self)
    }
    
    func trytoInt() throws -> Int {
        guard let double = self.toInt else {
            throw NSError(domain: "Cannot convert string to Int",
                          code: 0,
                          userInfo: nil)
        }
        
        return double
    }
    
    func trytoDouble() throws -> Double {
        guard let double = self.toDouble else {
            throw NSError(domain: "Cannot convert string to double",
                          code: 0,
                          userInfo: nil)
        }
        
        return double
    }
   
    
    func tryToDate(_ byDateFormat: String,
                   timezone: TimeZone? = nil,
                   locale: Locale? = nil,
                   calendar: Calendar? = nil) throws -> Date {
        guard
            let date = self.toDate(byDateFormat,
                                   timezone: timezone,
                                   locale: locale,
                                   calendar: calendar)
        else { throw StringError.errorOnConvertion }
        
        return date
    }
    
}
