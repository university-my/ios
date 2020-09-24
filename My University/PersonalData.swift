//
//  PersonalData.swift
//  My University
//
//  Created by Oleksandr Kysil on 9/2/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct UserData {
    
    static var firstUsage: Date? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.firstUsage) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.firstUsage)
        }
    }

    /// For show a controller with information what's new in version 1.7.2
    static var whatsNew1_7_2: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.whatsNew1_7_2)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.whatsNew1_7_2)
        }
    }

    /// Register default values of user
    static func registerDefaultValues() {
        let settings: [String: Any] = [
            UserDefaultsKey.whatsNew1_7_2: true
        ]
        UserDefaults.standard.register(defaults: settings)
        UserDefaults.standard.synchronize()
    }
}
