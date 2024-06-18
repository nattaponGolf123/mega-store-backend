//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation

struct ProductCode {
    @RunningCode(prefix: "P")
    var code: String
    
    init(number: Int) {
        _code = RunningCode(prefix: "P", runningNumber: number)
    }
    
    static func getNumber(from code: String) -> Int? {
        
       //remove all alphabel from code
        let number = code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let number = Int(number) {
            return number
        }
        
        return nil
        
    }
}
