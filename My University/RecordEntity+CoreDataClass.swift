//
//  RecordEntity+CoreDataClass.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(RecordEntity)
public class RecordEntity: NSManagedObject {

    var title: String {
        var title = ""
        // Name
        if let name = name {
            title = name
        }
        // Type
        if let type = type, type.isEmpty == false {
            if title.isEmpty {
                title = type
            } else {
                title += "\n" + type
            }
        }
        return title
    }
    
    var detail: String {
        var detail = ""
        // Auditorium
        if let auditorium = auditorium, let name = auditorium.name {
            detail = name + "\n"
        }
        // Name and time
        if let pairName = pairName, let time = time {
            detail += pairName + " (\(time))"
        } else if let time = time {
            detail += "(\(time))"
        }
        return detail
    }
    
    static func fetch(id: Int64, context: NSManagedObjectContext) -> RecordEntity? {
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let entity = result.first
            return entity
        } catch  {
            return nil
        }
    }
}
