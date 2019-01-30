//
//  Collection.swift
//  My University
//
//  Created by Yura Voevodin on 1/30/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

public extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
