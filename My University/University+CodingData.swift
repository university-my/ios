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
        
        let id: Int64
        let fullName: String
        let shortName: String
        let url: String
        let isHidden: Bool
        let isBeta: Bool
        let pictureWhite: String?
        let pictureDark: String?
        let showClassrooms: Bool
        let showGroups: Bool
        let showTeachers: Bool
        
        var serverID: Int64 {
            id
        }
    }
}
