//
//  Collection.swift
//  My University
//
//  Created by Yura Voevodin on 15.09.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

public extension Collection {

    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
