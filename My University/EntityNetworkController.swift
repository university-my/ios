//
//  EntityNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 02.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityNetworkControllerDelegate: class {
    func didImportRecords(for structure: EntityStructRepresentable, _ error: Error?)
}

class EntityNetworkController<T> {
    
    typealias StructType = T
    weak var delegate: EntityNetworkControllerDelegate?
}
