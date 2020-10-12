//
//  ClassroomEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 12.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClassroomEntity)
public class ClassroomEntity: NSManagedObject {

    class func fetch(_ classrooms: [Classroom.CodingData], university: UniversityEntity?, context: NSManagedObjectContext) -> [ClassroomEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let slugs = classrooms.map { classroom in
            return classroom.slug
        }
        let fetchRequest: NSFetchRequest<ClassroomEntity> = ClassroomEntity.fetchRequest()
        let slugPredicate = NSPredicate(format: "slug IN %@", slugs)
        let universityPredicate = NSPredicate(format: "university == %@", university)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [universityPredicate, slugPredicate])
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            return []
        }
    }
    
    static func fetchAll(university: UniversityEntity, context: NSManagedObjectContext) -> [ClassroomEntity] {
        let request: NSFetchRequest<ClassroomEntity> = ClassroomEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            return []
        }
    }
    
    /// Fetch classroom entity
    static func fetch(id: Int64, context: NSManagedObjectContext) -> ClassroomEntity? {
        let fetchRequest: NSFetchRequest<ClassroomEntity> = ClassroomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(fetchRequest)
            let classroom = result.first
            return classroom
        } catch {
            return nil
        }
    }
}

// MARK: - EntityProtocol

extension ClassroomEntity: EntityProtocol {
    
    var favorite: Bool {
        get {
            return isFavorite
        }
        set {
            isFavorite = newValue
        }
    }
    
    func shareURL(for date: Date) -> URL? {
        guard let parameters = pageParameters(with: date) else {
            return nil
        }
        return Classroom.Endpoints.websitePage(from: parameters).url
    }
}

// MARK: - StructRepresentable

extension ClassroomEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        guard let name = name else { return nil }
        guard let slug = slug else { return nil }
        return Classroom(id: id, isFavorite: isFavorite, name: name, slug: slug)
    }
}
