//
//  Entity.swift
//  My University
//
//  Created by Yura Voevodin on 13.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

struct Entity: Codable {

    let kind: Kind
    let id: Int64
    
    enum Kind: String, Codable {
        case auditorium
        case group
        case teacher
    }
}

extension Entity {
    
    static var lastOpened: Entity? {
        return Manager.shared.lastOpened
    }
}
