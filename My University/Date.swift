//
//  Date.swift
//  My University
//
//  Created by Oleksandr Kysil on 5/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
    }
}
