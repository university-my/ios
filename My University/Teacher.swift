//
//  Teacher.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import Foundation

struct Teacher {
    
    // MARK: - Properties
    
    let id: Int64
    let name: String
    let slug: String
    
    // MARK: - Initialization
    
    init?(_ json: [String: Any]) {
        guard let id = json["id"] as? Int64 else { return nil }
        guard let name = json["name"] as? String else { return nil }
        guard let slug = json["slug"] as? String else { return nil }
        self.id = id
        self.name = name
        self.slug = slug
    }
}
