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
    
    private static var identifier: String {
        Bundle.identifier
    }
    
    static var recordDetailsOpenedCountKey: String {
        "\(identifier).recordDetailsOpenedCount"
    }
    
    static var currentUniversityKey: String {
        "\(identifier).currentUniversity"
    }
    
    static var latestVersionPromptedForReviewKey: String {
        "\(identifier).latestVersionPromptedForReview"
    }
    
    static var latestVersionForNewFeaturesKey: String {
        "\(identifier).latestVersionForNewFeatures"
    }
    
    static func entityKey(with type: String, universityID: Int64) -> String {
        "\(identifier).\(universityID).\(type)"
    }
}
