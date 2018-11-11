//
//  GroupStruct.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

struct Group {
    
    // MARK: - Properties
    
    let id: Int64
    let name: String
    
    // MARK: - Initialization
    
    init?(_ json: [String: Any]) {
        guard let id = json["id"] as? Int64 else { return nil }
        guard let name = json["name"] as? String else { return nil }
        self.id = id
        self.name = name
    }
}
