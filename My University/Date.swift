//
//  Date.swift
//  My University
//
//  Created by Oleksandr Kysil on 5/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

extension Date {
    
    func plusSevenDays() -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        return gregorian.date(byAdding: .day, value: 7, to: self) ?? self
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
    }
}
