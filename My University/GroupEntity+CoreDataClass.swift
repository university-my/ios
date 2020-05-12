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
    class func fetch(_ groups: [Group.CodingData], university: UniversityEntity?, context: NSManagedObjectContext) -> [GroupEntity] {
        // University should not be nil
        guard let university = university else { return [] }
        
        let slugs = groups.map { group in
            return group.slug
        }
        let fetchRequest: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
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
}

// MARK: - FavoriteEntityProtocol

extension GroupEntity: FavoriteEntityProtocol {
    
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

extension GroupEntity: EntityProtocol {
    
    func shareURL(for date: Date) -> URL? {
        guard let universityURL = university?.url else { return nil }
        guard let slug = slug else { return nil }
        let dateString = DateFormatter.short.string(from: date)
        return Group.Endpoint.page(for: slug, university: universityURL, date: dateString).url
    }
}

// MARK: - StructRepresentable

extension GroupEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        guard let name = name else { return nil }
        guard let slug = slug else { return nil }
        return Group(id: id, name: name, slug: slug, isFavorite: isFavorite)
    }
}
