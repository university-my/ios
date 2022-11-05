//
//  Record+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    struct CodingData: Codable, Identifiable {
        
        // MARK: - Properties
        
        let id: Int64
        let time: String
        let dateString: String
        
        /// Type of the pair (lecture or practical work)
        let type: String?
        
        /// Name of the pair (discipline)
        let name: String?
        let pairName: String
        
        /// Description or comment
        let reason: String?
        let classroom: ModelCodingData?
        let groups: [ModelCodingData]
        let teacher: ModelCodingData?
        
        enum CodingKeys: String, CodingKey {
            case id
            case time
            case dateString = "pair_start_date"
            case `type` = "kind"
            case name
            case pairName = "pair_name"
            case reason
            case classroom = "auditorium"
            case groups
            case teacher
        }
    }
}

extension Record.CodingData {
    
    var date: Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.date(from: dateString)
    }
}

extension Record.CodingData {
    var sectionName: String {
        var sectionName = ""
        
        if !pairName.isEmpty {
            sectionName = pairName
        }
        if !time.isEmpty {
            sectionName += " (\(time))"
        }
        return sectionName
    }
}
