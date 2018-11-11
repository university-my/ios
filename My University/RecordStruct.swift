//
//  RecordStruct.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

struct RecordStruct {
    
    // MARK: - Properties
    
    let id: Int
    let time: String
    let dateString: String
    let date: Date?
    let type: String?
    let name: String?
    let pairName: String
    let reason: String?
    
    // MARK: - Initialization
    
    init?(_ json: [String: Any], dateFormatter: DateFormatter) {
        guard let id = json["id"] as? Int else { return nil }
        guard let time = json["time"] as? String else { return nil }
        guard let dateString = json["date_string"] as? String else { return nil }
        let type = json["type"] as? String
        let name = json["name"] as? String
        guard let pairName = json["pair_name"] as? String else { return nil }
        let reason = json["reason"] as? String
        
        self.id = id
        self.time = time
        self.dateString = dateString
        self.type = type
        self.name = name
        self.pairName = pairName
        self.reason = reason
        
        // Date
        self.date = dateFormatter.date(from: dateString)
    }
}
