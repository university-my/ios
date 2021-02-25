//
//  UniversityEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UniversityEntity)
public class UniversityEntity: NSManagedObject {
    
    // MARK: - Methods

    static func fetch(_ ids: [Int64], context: NSManagedObjectContext) -> [UniversityEntity] {
        let request: NSFetchRequest<UniversityEntity> = UniversityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(context: NSManagedObjectContext) -> [UniversityEntity] {
        let request: NSFetchRequest<UniversityEntity> = UniversityEntity.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }

    static func fetch(id: Int64, context: NSManagedObjectContext) -> UniversityEntity? {
        let fetchRequest: NSFetchRequest<UniversityEntity> = UniversityEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let entity = result.first
            return entity
        } catch  {
            return nil
        }
    }
    
    static func search(with query: String, context: NSManagedObjectContext) -> [UniversityEntity] {
        let fetchRequest: NSFetchRequest<UniversityEntity> = UniversityEntity.fetchRequest()
        
        let name = NSSortDescriptor(key: #keyPath(UniversityEntity.shortName), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        fetchRequest.sortDescriptors = [name]
        fetchRequest.fetchBatchSize = 20
        
        let predicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [
                NSPredicate(format: "fullName CONTAINS[cd] %@", query),
                NSPredicate(format: "shortName CONTAINS[cd] %@", query)
            ]
        )
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
}
