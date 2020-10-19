//
//  UserDefaultsKeys.swift
//  My University
//
//  Created by Yura Voevodin on 30.09.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

/*
Abstract:
A class used to provide keys for UserDefaults.
*/

import Foundation

struct UserDefaultsKeys {
    
    static var recordDetailsOpenedCountKey: String {
        return Bundle.identifier + ".recordDetailsOpenedCount"
    }
    
    static var selectedUniversityKey: String {
        return Bundle.identifier + ".selectedUniversity"
    }
    
    static var lastVersionPromptedForReviewKey: String {
        return Bundle.identifier + ".lastVersionPromptedForReview"
    }
    
    static var lastVersionForNewFeaturesKey: String {
        return Bundle.identifier + ".lastVersionForNewFeatures"
    }
    
    static func entityKey(with type: String, universityID: Int64) -> String {
        return "\(Bundle.identifier).\(universityID).\(type)"
    }
}
