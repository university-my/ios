//
//  Filter.swift
//  My University
//
//  Created by Oleksandr Kysil on 5/23/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

enum Period: Int {

    case today = 0
    case week

    var title: String {
        switch self {
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .week:
            return NSLocalizedString("Week", comment: "")
        }
    }
    
    static var key: String {
        get {
            if let bundle = Bundle.main.bundleIdentifier {
                return bundle + ".period"
            }
            return "period"
        }
    }

    static var current: Period {
        get {
            let integer = UserDefaults.standard.integer(forKey: key)
            if let currentPeriod = Period(rawValue: integer) {
                return currentPeriod
            } else {
                return .week
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
