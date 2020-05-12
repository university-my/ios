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
    class func fetch(_ auditoriums: [Auditorium.CodingData], university: UniversityEntity?, context: NSManagedObjectContext) -> [AuditoriumEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let slugs = auditoriums.map { auditorium in
            return auditorium.slug
        }
        let fetchRequest: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
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
}

// MARK: - FavoriteEntityProtocol

extension AuditoriumEntity: FavoriteEntityProtocol {
    
    var favorite: Bool {
        get {
            return isFavorite
        }
        set {
            isFavorite = newValue
        }
    }
}

// MARK: - EntityProtocol

extension AuditoriumEntity: EntityProtocol {
    
    func shareURL(for date: Date) -> URL? {
        guard let universityURL = university?.url else { return nil }
        guard let slug = slug else { return nil }
        let dateString = DateFormatter.short.string(from: date)
        return Auditorium.Endpoint.page(for: slug, university: universityURL, date: dateString).url
    }
}

// MARK: - StructRepresentable

extension AuditoriumEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        guard let name = name else { return nil }
        guard let slug = slug else { return nil }
        return Auditorium(id: id, isFavorite: isFavorite, name: name, slug: slug)
    }
}
