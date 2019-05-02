//
//  UniversityEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 4/18/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension UniversityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UniversityEntity> {
        return NSFetchRequest<UniversityEntity>(entityName: "UniversityEntity")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var shortName: String?
    @NSManaged public var url: String?
    @NSManaged public var id: Int64
    @NSManaged public var auditoriums: NSSet?
    @NSManaged public var groups: NSSet?
    @NSManaged public var teachers: NSSet?

}

// MARK: Generated accessors for auditoriums
extension UniversityEntity {

    @objc(addAuditoriumsObject:)
    @NSManaged public func addToAuditoriums(_ value: AuditoriumEntity)

    @objc(removeAuditoriumsObject:)
    @NSManaged public func removeFromAuditoriums(_ value: AuditoriumEntity)

    @objc(addAuditoriums:)
    @NSManaged public func addToAuditoriums(_ values: NSSet)

    @objc(removeAuditoriums:)
    @NSManaged public func removeFromAuditoriums(_ values: NSSet)

}

// MARK: Generated accessors for groups
extension UniversityEntity {

    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: GroupEntity)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: GroupEntity)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)

}

// MARK: Generated accessors for teachers
extension UniversityEntity {

    @objc(addTeachersObject:)
    @NSManaged public func addToTeachers(_ value: TeacherEntity)

    @objc(removeTeachersObject:)
    @NSManaged public func removeFromTeachers(_ value: TeacherEntity)

    @objc(addTeachers:)
    @NSManaged public func addToTeachers(_ values: NSSet)

    @objc(removeTeachers:)
    @NSManaged public func removeFromTeachers(_ values: NSSet)

}
