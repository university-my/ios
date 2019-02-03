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
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let result = try context.fetch(request)
            return result.first
        } catch {
            return nil
        }
    }
    
    /// Fetch groups
    class func fetch(_ groups: [Group], context: NSManagedObjectContext) -> [GroupEntity] {
        let ids = groups.map { group in
            return group.id
        }
        let fetchRequest: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func clearHistory(on context: NSManagedObjectContext) {
        let request = NSBatchUpdateRequest(entityName: "GroupEntity")
        
        let isVisited = #keyPath(GroupEntity.isVisited)
        
        request.predicate = NSPredicate(format: isVisited + " == YES")
        request.propertiesToUpdate = [isVisited: "NO"]
        request.resultType = .updatedObjectIDsResultType
        do {
            let result = try context.execute(request) as? NSBatchUpdateResult
            
            if let objectIDArray = result?.result as? [NSManagedObjectID] {
                let changes = [NSUpdatedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
        } catch {
        }
    }
}
