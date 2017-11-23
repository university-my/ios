//
//  RecordEntity+CoreDataProperties.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension RecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntity> {
        return NSFetchRequest<RecordEntity>(entityName: "RecordEntity")
    }

    @NSManaged public var time: String
    @NSManaged public var dateString: String?
    @NSManaged public var type: String?
    @NSManaged public var name: String?
    @NSManaged public var pairName: String
    @NSManaged public var reason: String?

}
