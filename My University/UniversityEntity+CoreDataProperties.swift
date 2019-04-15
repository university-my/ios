//
//  UniversityEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension UniversityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UniversityEntity> {
        return NSFetchRequest<UniversityEntity>(entityName: "UniversityEntity")
    }

    @NSManaged public var shortName: String?
    @NSManaged public var fullName: String?
    @NSManaged public var url: String?

}
