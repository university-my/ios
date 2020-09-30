//
//  UpdateHelper.swift
//  My University
//
//  Created by Yura Voevodin on 30.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct UpdateHelper {
    
    enum EntityType: String {
        case auditorium = "auditorium"
        case group = "group"
        case teacher = "teacher"
    }
    
    /// Returns `true` if there are more than one day between current date and last synchronization date
    static func needToUpdate(from lastSynchronization: Date) -> Bool {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let currentDate = calendar.startOfDay(for: Date())
        let synchronization = calendar.startOfDay(for: lastSynchronization)
        
        let components = calendar.dateComponents([.day], from: currentDate, to: synchronization)
        
        // This will return the number of day(s) between dates
        guard let days = components.day else {
            return false
        }
        if days >= 1 {
            return true
        } else if days < 0 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Last updated
    
    static func lastUpdated(for universityID: Int64, type: EntityType) -> Date {
        let key = UserDefaultsKeys.entityKey(with: type.rawValue, universityID: universityID)
        if let date = UserDefaults.standard.value(forKey: key) as? Date {
            return date
        } else {
            return Date(timeIntervalSince1970: 1)
        }
    }
    
    static func updated(at date: Date, universityID: Int64, type: EntityType) {
        let key = UserDefaultsKeys.entityKey(with: type.rawValue, universityID: universityID)
        UserDefaults.standard.set(date, forKey: key)
    }
    
}
