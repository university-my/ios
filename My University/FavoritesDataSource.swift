//
//  FavoritesDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 6/1/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class FavoritesDataSource: NSObject {

    // MARK: - Types

    struct Section {

        let kind: Kind

        enum Kind {
            case auditoriums
            case groups
            case teachers
        }

        var name: String {
            switch kind {
            case .auditoriums:
                return NSLocalizedString("Auditoriums", comment: "Favorites section name")
            case .groups:
                return NSLocalizedString("Groups", comment: "Favorites section name")
            case .teachers:
                return NSLocalizedString("Teachers", comment: "Favorites section name")
            }
        }
    }

    // MARK: - University

    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()

    var university: UniversityEntity?

    func fetchUniversity(with id: Int64) {
        guard let context = viewContext else { return }
        university = UniversityEntity.fetch(id: id, context: context)
    }

    // MARK: - Auditoriums

    lazy var auditoriums: NSFetchedResultsController<AuditoriumEntity>? = {
        guard let university = university else { return nil }

        let request: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@ AND isFavorite == YES", university)

        let name = NSSortDescriptor(key: #keyPath(AuditoriumEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))

        request.sortDescriptors = [name]
        request.fetchBatchSize = 20

        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()

    func fetchAuditoriums() {
        do {
            try auditoriums?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }

    // MARK: - Groups

    lazy var groups: NSFetchedResultsController<GroupEntity>? = {
        guard let university = university else { return nil }

        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@ AND isFavorite == YES", university)

        let name = NSSortDescriptor(key: #keyPath(GroupEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))

        request.sortDescriptors = [name]
        request.fetchBatchSize = 20

        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()

    func fetchGroups() {
        do {
            try groups?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }

    // MARK: - Teachers

    lazy var teachers: NSFetchedResultsController<TeacherEntity>? = {
        guard let university = university else { return nil }

        let request: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@ AND isFavorite == YES", university)

        let name = NSSortDescriptor(key: #keyPath(TeacherEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))

        request.sortDescriptors = [name]
        request.fetchBatchSize = 20

        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()

    func fetchTeachers() {
        do {
            try teachers?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }

    // MARK: - Sections

    var sections: [Section] = []

    func configureSections() {
        var newSections: [Section] = []

        if groups?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .groups))
        }
        if teachers?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .teachers))
        }
        if auditoriums?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .auditoriums))
        }

        sections = newSections
    }
}
