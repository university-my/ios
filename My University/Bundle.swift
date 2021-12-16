//
//  Bundle.swift
//  My University
//
//  Created by Yura Voevodin on 20.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// Identifier of app main bundle
    static var identifier: String {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return bundleIdentifier
        } else {
            return "com.voevodin-yura.Schedule"
        }
    }
    
    /// App "version" string (1.0.0 etc.)
    var shortVersion: String? {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
