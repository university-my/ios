//
//  Model+CoreData.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

extension Model {
    
    static func fetchEntity(with id: Int64, in context: NSManagedObjectContext) -> CoreDataEntity? {
        let fetchRequest: NSFetchRequest<CoreDataEntity> = CoreDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let entity = result.first
            return entity
        } catch  {
            return nil
        }
    }
    
    static func fetch(_ objects: [CodingData], for university: UniversityEntity, in context: NSManagedObjectContext) -> [CoreDataEntity] {
        let slugs = objects.map { $0.slug }
        
        let fetchRequest: NSFetchRequest<CoreDataEntity> = CoreDataEntity.fetchRequest()
        
        let idsPredicate = NSPredicate(format: "slug IN %@", slugs)
        let universityPredicate = NSPredicate(format: "university == %@", university)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [universityPredicate, idsPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(for university: UniversityEntity, in context: NSManagedObjectContext) -> [CoreDataEntity] {
        let request: NSFetchRequest<CoreDataEntity> = CoreDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    static func fetchRequestPredicate(for entity: Entity) -> NSPredicate {
        switch entity {
        case is ClassroomEntity:
            return NSPredicate(format: "classroom == %@", entity)
        case is GroupEntity:
            return NSPredicate(format: "ANY groups == %@", entity)
        case is TeacherEntity:
            return NSPredicate(format: "teacher == %@", entity)
        default:
            preconditionFailure()
        }
    }
}
