//
//  UniversityLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 30.09.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension UniversityViewController {
    
    final class UniversityLogicController {
        
        // MARK: - What's New
        
        func needToPresentWhatsNew() -> Bool {
            let currentVersion = Bundle.appVersion
            
            let lastVersionForNewFeatures = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionForNewFeaturesKey)
            
            if currentVersion != lastVersionForNewFeatures {
                return true
            } else {
                return false
            }
        }
        
        func updateLastVersionForNewFeatures()  {
            let currentVersion = Bundle.appVersion
            UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionForNewFeaturesKey)
        }
        
        func resetLastVersionForNewFeatures() {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastVersionForNewFeaturesKey)
        }
        
    }
    
}
