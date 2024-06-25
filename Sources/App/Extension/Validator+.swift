//
//  Calendar+.swift
//  HomemadeStay
//
//  Created by IntrodexMac on 8/6/2567 BE.
//  Copyright © 2567 BE Fire One One Co., Ltd. All rights reserved.
//

import Foundation
import Vapor

extension Validator where T == String {
    /// Validates whether a string is a valid date with the specified format.
    static func date(format: String = "yyyy-MM-dd") -> Validator<T> {
        Validator { input in
            guard
                let _ = input.toDate(format)
            else {
                return ValidatorResults.DateFormat(isValid: false,
                                                   format: format)
            }
            
            return ValidatorResults.DateFormat(isValid: true,
                                               format: format)
        }
    }
}

extension ValidatorResults {
    
    public struct DateFormat {
        public let isValid: Bool
        public let format: String
    }
    
}

extension ValidatorResults.DateFormat: ValidatorResult {
    public var isFailure: Bool {
        !isValid
    }
    
    public var successDescription: String? {
        "date is in the correct format"
    }
    
    public var failureDescription: String? {
        "date must be in the format \(format)"
    }
}
