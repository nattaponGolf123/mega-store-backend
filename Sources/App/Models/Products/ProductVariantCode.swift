//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation

struct ProductVariantCode {
    let code: String
    
    init(productCode: String,
         number: Int) {
        self.code = "\(productCode)-\(number)"
    }
}
