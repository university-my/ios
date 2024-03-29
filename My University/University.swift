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
    
    static func select(_ university: University.CodingData) {
        current = university
    }
    
    static func removeCurrent() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentUniversityKey)
    }
    
    private(set) static var current: University.CodingData? {
        get {
            guard let data = UserDefaults.standard.object(forKey: UserDefaultsKeys.currentUniversityKey) as? Data else {
                return nil
            }
            let decoder = JSONDecoder()
            let university = try? decoder.decode(University.CodingData.self, from: data)
            return university
        }
        set {
            let jsonEncoder = JSONEncoder()
            if let jsonData = try? jsonEncoder.encode(newValue) {
                UserDefaults.standard.set(jsonData, forKey: UserDefaultsKeys.currentUniversityKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
}
