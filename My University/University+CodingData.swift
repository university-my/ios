//
//  University+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension University {
    
    struct CodingData: Codable {
        
        let serverID: Int64
        let fullName: String
        let shortName: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case serverID = "id"
            case fullName = "full_name"
            case shortName = "short_name"
            case url
        }
    }
}
