//
//  PersonalData.swift
//  My University
//
//  Created by Oleksandr Kysil on 9/2/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct UserData {
    
    // MARK: - Enum
    
    enum Keys: String {
        case firstUsage
        
        // MARK: - Variables
        
        private var prefix: String {
            get {
                if let bundle = Bundle.main.bundleIdentifier {
                    return bundle + "userData"
                }
                return "userData"
            }
        }
        
        var value: String {
            switch self {
            case .firstUsage:
                return prefix + self.rawValue
            }
        }
    }
    
    static var firstUsage: Date? {
        get {
            return UserDefaults.standard.object(forKey: Keys.firstUsage.value) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.firstUsage.value)
        }
    }
}
