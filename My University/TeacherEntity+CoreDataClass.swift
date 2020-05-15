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
    
    static func fetch(_ teachers: [Teacher.CodingData], university: UniversityEntity?, context: NSManagedObjectContext) -> [TeacherEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let slugs = teachers.map { group in
            return group.slug
        }
        let fetchRequest: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        let isdPredicate = NSPredicate(format: "slug IN %@", slugs)
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

// MARK: - EntityProtocol

extension TeacherEntity: EntityProtocol {
    
    var favorite: Bool {
        get {
            return isFavorite
        }
        set {
            isFavorite = newValue
        }
    }
    
    func shareURL(for date: Date) -> URL? {
        guard let universityURL = university?.url else { return nil }
        guard let slug = slug else { return nil }
        let dateString = DateFormatter.short.string(from: date)
        return Teacher.Endpoint.page(for: slug, university: universityURL, date: dateString).url
    }
}

// MARK: - StructRepresentable

extension TeacherEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        return Teacher(
            firstSymbol: firstSymbol,
            id: id,
            isFavorite: isFavorite,
            name: name,
            slug: slug
        )
    }
}
