//
//  TeacherEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TeacherEntity)
public class TeacherEntity: NSManagedObject {

    /// Fetch teacher entity
    static func fetchTeacher(id: Int64, context: NSManagedObjectContext) -> TeacherEntity? {
        let fetchRequest: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let auditorium = result.first
            return auditorium
        } catch  {
            return nil
        }
    }
    
    static func clearHistory(on context: NSManagedObjectContext) {
        let request = NSBatchUpdateRequest(entityName: "TeacherEntity")
        
        let isVisited = #keyPath(TeacherEntity.isVisited)
        
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
