//
//  Filter.swift
//  My University
//
//  Created by Oleksandr Kysil on 5/23/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

enum Filter: Int {
    case day = 0
    case week
    case month
    
    static var key: String {
        get {
            if let bundle = Bundle.main.bundleIdentifier {
                return bundle + "filterData"
            }
            return "filterData"
        }
    }
    
    static var currentType: Int {
        get {
            return UserDefaults.standard.integer(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
}
