//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation

struct ServiceCode {
    @RunningCode(prefix: "S")
    var code: String
    
    init(number: Int) {
        _code = RunningCode(prefix: "S", runningNumber: number)
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
