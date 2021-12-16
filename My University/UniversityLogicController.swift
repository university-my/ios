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
        
        private var latestVersionKey: String {
            UserDefaultsKeys.latestVersionForNewFeaturesKey
        }
        
        func needToPresentWhatsNew() -> Bool {
            guard let currentVersion = Bundle.main.shortVersion else { return false }
            return needToPresentWhatsNew(for: currentVersion)
        }
        
        func needToPresentWhatsNew(for requestedVersion: String) -> Bool {
            let latestSavedVersion = UserDefaults.standard.string(forKey: latestVersionKey)
            
            // Don't show again for the same version
            if requestedVersion == latestSavedVersion {
                return false
            }
            
            // Show only for selected version
            return requestedVersion == "1.7.6"
        }
        
        func updateLastVersionForNewFeatures() {
            guard let currentVersion = Bundle.main.shortVersion else { return }
            updateLatestVersionForNewFeatures(to: currentVersion)
        }
        
        func updateLatestVersionForNewFeatures(to version: String)  {
            UserDefaults.standard.set(version, forKey: latestVersionKey)
        }
        
        func resetLatestVersionForNewFeatures() {
            UserDefaults.standard.removeObject(forKey: latestVersionKey)
        }
        
    }
    
}
