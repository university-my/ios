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
    
    let time: String
    let dateString: String
    let type: String?
    let name: String?
    let pairName: String
    let reason: String?
    
    // MARK: - Initialization
    
    init?(_ json: [String: Any]) {
        guard let time = json["time"] as? String else { return nil }
        guard let dateString = json["date_string"] as? String else { return nil }
        let type = json["type"] as? String
        let name = json["name"] as? String
        guard let pairName = json["pair_name"] as? String else { return nil }
        let reason = json["reason"] as? String
        
        self.time = time
        self.dateString = dateString
        self.type = type
        self.name = name
        self.pairName = pairName
        self.reason = reason
    }
}
