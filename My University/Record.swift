//
//  RecordStruct.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

struct Record {
    
    let auditorium: Auditorium?
    let date: Date?
    let groups: [Group]
    let id: Int64
    let name: String?
    let pairName: String?
    let reason: String?
    let teacher: Teacher?
    let time: String?
    let type: String?
}

extension Record {
    
    var title: String {
        var title = ""
        // Name
        if let name = name {
            title = name
        }
        return title
    }
    
    var detail: String {
        var detail = ""
        // Type
        if let type = type, type.isEmpty == false {
          detail = type
        }
        return detail
    }
}
