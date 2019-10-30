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
    
    /// Fetch groups
    class func fetch(_ auditoriums: [Auditorium], university: UniversityEntity?, context: NSManagedObjectContext) -> [AuditoriumEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let slugs = auditoriums.map { auditorium in
            return auditorium.slug
        }
        let fetchRequest: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "slug IN %@", slugs)
        let universityPredicate = NSPredicate(format: "university == %@", university)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [universityPredicate, isdPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            return []
        }
    }
    
    static func fetchAll(university: UniversityEntity, context: NSManagedObjectContext) -> [AuditoriumEntity] {
        let request: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// Fetch auditorium entity
    static func fetch(id: Int64, context: NSManagedObjectContext) -> AuditoriumEntity? {
        let fetchRequest: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let auditorium = result.first
            return auditorium
        } catch {
            return nil
        }
    }
    
    static func lastSynchronization(context: NSManagedObjectContext) -> Date {
        let fetchRequest: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        let updatedAt = NSSortDescriptor(key: #keyPath(AuditoriumEntity.updatedAt), ascending: false)
        fetchRequest.sortDescriptors = [updatedAt]
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest)
            if let auditorium = result.first, let updatedAt = auditorium.updatedAt {
                return updatedAt
            } else {
                return Date(timeIntervalSince1970: 1)
            }
        } catch {
            return Date(timeIntervalSince1970: 1)
        }
    }
}

extension AuditoriumEntity: ImportProtocol {}
