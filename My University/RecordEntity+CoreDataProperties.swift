//
//  RecordEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 1/9/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
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
    @NSManaged public var auditorium: AuditoriumEntity?
    @NSManaged public var groups: NSSet?

}

// MARK: Generated accessors for groups
extension RecordEntity {

    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: GroupEntity)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: GroupEntity)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)

}
