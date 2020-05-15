//
//  EntityNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 02.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityNetworkControllerDelegate: class {
    func didImportRecords(for structure: EntityRepresentable, _ error: Error?)
}

class EntityNetworkController {
    
    weak var delegate: EntityNetworkControllerDelegate?
}
