//
//  AuditoriumEntity+CoreDataProperties.swift
//  My University
//
//  Created by Yura Voevodin on 11/21/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData


extension AuditoriumEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuditoriumEntity> {
        return NSFetchRequest<AuditoriumEntity>(entityName: "AuditoriumEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var firstSymbol: String?
    @NSManaged public var records: RecordEntity?

}
