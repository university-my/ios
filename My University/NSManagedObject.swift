//
//  NSManagedObject.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

public extension NSManagedObject {
    
    /// NSManagedObject's subclass name
    static var entityName: String {
        return String(describing: self)
    }
}
