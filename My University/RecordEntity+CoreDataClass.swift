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
    
    static func fetch(id: Int64, context: NSManagedObjectContext) -> RecordEntity? {
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let entity = result.first
            return entity
        } catch  {
            return nil
        }
    }
    
    static func fetch(_ records: [Record], auditorium: AuditoriumEntity?, context: NSManagedObjectContext) -> [RecordEntity] {
        guard let auditorium = auditorium else { return [] }
        
        let ids = records.map { record in
            return record.id
        }
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "id IN %@", ids)
        let auditoriumPredicate = NSPredicate(format: "auditorium == %@", auditorium)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [auditoriumPredicate, isdPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetch(_ records: [Record], group: GroupEntity?, context: NSManagedObjectContext) -> [RecordEntity] {
        guard let group = group else { return [] }
        
        let ids = records.map { record in
            return record.id
        }
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "id IN %@", ids)
        let groupPredicate = NSPredicate(format: "ANY groups == %@", group)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, isdPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetch(_ records: [Record], teacher: TeacherEntity?, context: NSManagedObjectContext) -> [RecordEntity] {
        guard let teacher = teacher else { return [] }
        
        let ids = records.map { record in
            return record.id
        }
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "id IN %@", ids)
        let teacherPredicate = NSPredicate(format: "teacher == %@", teacher)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [teacherPredicate, isdPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(auditorium: AuditoriumEntity, context: NSManagedObjectContext) -> [RecordEntity] {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "auditorium == %@", auditorium)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(group: GroupEntity, context: NSManagedObjectContext) -> [RecordEntity] {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY groups == %@", group)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
    
    static func fetchAll(teacher: TeacherEntity, context: NSManagedObjectContext) -> [RecordEntity] {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "teacher == %@", teacher)
        do {
            let result = try context.fetch(request)
            return result
        } catch  {
            return []
        }
    }
}
