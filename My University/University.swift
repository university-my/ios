//
//  University.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct University {
    
    // MARK: - Selected University
    
    static var selectedUniversityID: Int64? {
        get {
            UserDefaults.standard.value(forKey: UserDefaultsKeys.selectedUniversityKey) as? Int64
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.selectedUniversityKey)
        }
    }
    
}
