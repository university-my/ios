//
//  StructRepresentable.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol StructRepresentable {
    func asStruct<StructType>() -> StructType
}
