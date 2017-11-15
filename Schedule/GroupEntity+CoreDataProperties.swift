//
//  GroupEntity+CoreDataProperties.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }
    
    @NSManaged public var firstSymbol: String
    @NSManaged public var id: Int64
    @NSManaged public var name: String
}
