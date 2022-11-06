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
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
    }
    
    static func dateRange(for date: Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let startData = calendar.date(byAdding: .weekOfMonth, value: -1, to: date)!
        let endDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: date)!
        return startData ... endDate
    }
}
