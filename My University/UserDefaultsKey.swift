//
//  UserDefaultsKey.swift
//  My University
//
//  Created by Yura Voevodin on 04.11.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

enum UserDefaultsKey {
    
    static var selectedUniversity: String {
        return Bundle.identifier + ".selected-university"
    }
    
    static func entity(with type: String, universityID: Int64) -> String {
        return "\(Bundle.identifier).\(universityID).\(type)"
    }
    
    static var firstUsage: String {
        return Bundle.identifier + ".first-usage"
    }

    static var whatsNew1_6_3: String {
        return Bundle.identifier + ".whatsNew1_6_3"
    }
}
