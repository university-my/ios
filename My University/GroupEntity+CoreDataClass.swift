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
    class func fetch(_ groups: [Group], university: UniversityEntity?, context: NSManagedObjectContext) -> [GroupEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let ids = groups.map { group in
            return group.id
        }
        let fetchRequest: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "id IN %@", ids)
        let universityPredicate = NSPredicate(format: "university == %@", university)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [universityPredicate, isdPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(university: UniversityEntity, context: NSManagedObjectContext) -> [GroupEntity] {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
    
    /// Check If Group is added to Favorite
    static func isFavorite(id: Int64, context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d AND isFavorite == YES", id)
        do {
            let result = try context.fetch(fetchRequest)
            if result.count == 1 {
                return true
            } else {
                return false
            }
        } catch  {
            print("Error in the fetched results controller: \(error).")
            return false
        }
    }
}
