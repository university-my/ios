//
//  UniversityEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 25.02.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension UniversityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UniversityEntity> {
        return NSFetchRequest<UniversityEntity>(entityName: "UniversityEntity")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var id: Int64
    @NSManaged public var shortName: String?
    @NSManaged public var url: String?
    @NSManaged public var isHidden: Bool
    @NSManaged public var isBeta: Bool
    @NSManaged public var pictureWhite: String?
    @NSManaged public var pictureDark: String?
    @NSManaged public var showClassrooms: Bool
    @NSManaged public var showGroups: Bool
    @NSManaged public var showTeachers: Bool
    @NSManaged public var classrooms: NSSet?
    @NSManaged public var groups: NSSet?
    @NSManaged public var teachers: NSSet?

}

// MARK: Generated accessors for classrooms
extension UniversityEntity {

    @objc(addClassroomsObject:)
    @NSManaged public func addToClassrooms(_ value: ClassroomEntity)

    @objc(removeClassroomsObject:)
    @NSManaged public func removeFromClassrooms(_ value: ClassroomEntity)

    @objc(addClassrooms:)
    @NSManaged public func addToClassrooms(_ values: NSSet)

    @objc(removeClassrooms:)
    @NSManaged public func removeFromClassrooms(_ values: NSSet)

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

extension UniversityEntity : Identifiable {

}
