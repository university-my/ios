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
            let teacher = result.first
            return teacher
        } catch  {
            return nil
        }
    }
    
    static func fetch(_ teachers: [Teacher], university: UniversityEntity?, context: NSManagedObjectContext) -> [TeacherEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let ids = teachers.map { group in
            return group.id
        }
        let fetchRequest: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
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
    
    static func fetchAll(university: UniversityEntity, context: NSManagedObjectContext) -> [TeacherEntity] {
        let request: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
}
