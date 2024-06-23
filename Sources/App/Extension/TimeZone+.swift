//
//  Timezone+.swift
//  HomemadeStay
//
//  Created by IntrodexMac on 8/6/2567 BE.
//  Copyright © 2567 BE Fire One One Co., Ltd. All rights reserved.
//

import Foundation

extension TimeZone {
    
    // England +00:00
    static var zero: TimeZone { TimeZone(secondsFromGMT: 0)! }
    
    // Bangkok +07:00
    static var bangkok: TimeZone { TimeZone(identifier: "Asia/Bangkok")! }
}
