//
//  GroupEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 16.12.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }

    @NSManaged public var firstSymbol: String?
    @NSManaged public var id: Int64
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var slug: String?
    @NSManaged public var uuid: UUID?
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

extension GroupEntity : Identifiable {

}
