//
//  EntityDataControllerProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 02.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityDataControllerProtocol {
    
    /// Override in subclasses
    func loadData()
    
    /// Override in subclasses
    func generatePredicate() -> NSPredicate?
}
