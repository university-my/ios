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
}
