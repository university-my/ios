//
//  RecordEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension RecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntity> {
        return NSFetchRequest<RecordEntity>(entityName: "RecordEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var pairName: String?
    @NSManaged public var reason: String?
    @NSManaged public var time: String?
    @NSManaged public var type: String?
    @NSManaged public var group: GroupEntity?

}
