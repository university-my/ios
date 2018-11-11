//
//  GroupEntity+CoreDataClass.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(GroupEntity)
public class GroupEntity: NSManagedObject {

    class func fetch(id: Int64, context: NSManagedObjectContext) -> GroupEntity? {
        let request: NSFetchRequest<GroupEntity> = fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", String(id))
        
        do {
            let result = try context.fetch(request)
            return result.first
        } catch {
            print(error)
            return nil
        }
    }
}
