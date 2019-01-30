//
//  AuditoriumEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(AuditoriumEntity)
public class AuditoriumEntity: NSManagedObject {
    
    static func clearHistory(on context: NSManagedObjectContext) {
        let request = NSBatchUpdateRequest(entityName: "AuditoriumEntity")
        
        let isVisited = #keyPath(AuditoriumEntity.isVisited)
        
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
