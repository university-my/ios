//
//  CoreDataFetchable.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataFetchable: NSManagedObject {
    typealias CoreDataType = Self
}

extension CoreDataFetchable {
    
    public static func fetchRequest() -> NSFetchRequest<CoreDataType> {
        return NSFetchRequest<CoreDataType>(entityName: CoreDataType.entityName)
    }
}
