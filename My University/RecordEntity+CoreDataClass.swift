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
    
    static func clearHistory(persistentContainer: NSPersistentContainer, _ completion: @escaping ((_ error: Error?) -> ())) {
        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDArray = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDArray]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context, persistentContainer.viewContext])
                }
            } catch {
                completion(error)
            }
            context.reset()
            persistentContainer.viewContext.refreshAllObjects()
            completion(nil)
        }
    }
}
