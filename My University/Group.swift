//
//  GroupStruct.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

struct Group {
    
    let id: Int64
    let name: String
    let slug: String
    let isFavorite: Bool
}

extension Group: EntityRepresentable {}
