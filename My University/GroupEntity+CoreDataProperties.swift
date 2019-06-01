//
//  GroupEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 4/18/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var firstSymbol: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var records: NSSet?
    @NSManaged public var university: UniversityEntity?

}

// MARK: Generated accessors for records
extension GroupEntity {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: RecordEntity)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: RecordEntity)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}
