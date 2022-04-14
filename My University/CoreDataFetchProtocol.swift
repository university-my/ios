//
//  CoreDataFetchProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataFetchProtocol: NSManagedObject {
    typealias CoreDataType = Self
}

extension CoreDataFetchProtocol {
    
    public static func fetchRequest() -> NSFetchRequest<CoreDataType> {
        NSFetchRequest<CoreDataType>(entityName: CoreDataType.entityName)
    }
}
