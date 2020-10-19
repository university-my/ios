//
//  UniversityDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 5/3/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit
import os

class UniversityDataSource: NSObject {
    
    private let logger = Logger(subsystem: Bundle.identifier, category: "UniversityDataSource")
    
    // MARK: - Types
    
    struct Section {
        
        let kind: Kind
        
        enum Kind {
            case classrooms
            case groups
            case teachers
            case university
        }
        
        var name: String? {
            switch kind {
            case .university:
                return nil
            case .classrooms:
                return NSLocalizedString("Classrooms", comment: "Favorites section name")
            case .groups:
                return NSLocalizedString("Groups", comment: "Favorites section name")
            case .teachers:
                return NSLocalizedString("Teachers", comment: "Favorites section name")
            }
        }
    }
    
    struct UniversityRow {
        
        let kind: Kind
        
        enum Kind {
            case classrooms
            case groups
            case teachers
        }
    }
    
    // MARK: - University
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    private(set) var university: UniversityEntity?
    
    func fetch(id: Int64) {
        guard let context = viewContext else { return }
        university = UniversityEntity.fetch(id: id, context: context)
    }
    
    private(set) var universityRows: [UniversityRow] = []
    
    // MARK: - Sections
    
    var sections: [Section] = []
    
    func configureSections() {
        guard let university = university else { return }
        
        var newSections: [Section] = []
        
        // Groups
        if groups?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .groups))
        }
        
        // Teachers
        if teachers?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .teachers))
        }
        
        // Classrooms
        if classrooms?.fetchedObjects?.isEmpty == false {
            newSections.append(Section(kind: .classrooms))
        }
        
        // University
        var rows: [UniversityRow] = []
        
        if university.isKPI {
            let groups = UniversityRow(kind: .groups)
            let teachers = UniversityRow(kind: .teachers)
            rows = [groups, teachers]
        } else {
            let groups = UniversityRow(kind: .groups)
            let teachers = UniversityRow(kind: .teachers)
            let classrooms = UniversityRow(kind: .classrooms)
            rows = [groups, teachers, classrooms]
        }
        universityRows = rows
        newSections.append(Section(kind: .university))
        
        sections = newSections
    }
    
    func titleForFooter(in section: Int) -> String? {
        guard let section = sections[safe: section] else { return nil }
        switch section.kind {
        case .classrooms, .groups, .teachers:
            return nil
        case .university:
            return university?.fullName
        }
    }
    
    func titleForHeader(in section: Int) -> String? {
        guard let section = sections[safe: section] else { return nil }
        switch section.kind {
        
        case .classrooms:
            if let classrooms = classrooms?.fetchedObjects, classrooms.count > 1 {
                return section.name
            } else {
                return NSLocalizedString("Classroom", comment: "Favorites section name")
            }
            
        case .groups:
            if let groups = groups?.fetchedObjects, groups.count > 1 {
                return section.name
            } else {
                return NSLocalizedString("Group", comment: "Favorites section name")
            }
            
        case .teachers:
            if let teachers = teachers?.fetchedObjects, teachers.count > 1 {
                return section.name
            } else {
                return NSLocalizedString("Teacher", comment: "Favorites section name")
            }
            
        case .university:
            return nil
        }
    }
    
    // MARK: - Favorites
    
    func fetchFavorites(delegate: NSFetchedResultsControllerDelegate) {
        fetchGroups(delegate: delegate)
        fetchTeachers(delegate: delegate)
        fetchClassrooms(delegate: delegate)
    }
    
    // MARK: - Classrooms
    
    lazy var classrooms: NSFetchedResultsController<ClassroomEntity>? = {
        guard let university = university else { return nil }
        
        let request: NSFetchRequest<ClassroomEntity> = ClassroomEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@ AND isFavorite == YES", university)
        
        let name = NSSortDescriptor(key: #keyPath(ClassroomEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [name]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private func fetchClassrooms(delegate: NSFetchedResultsControllerDelegate) {
        do {
            classrooms?.delegate = delegate
            try classrooms?.performFetch()
        } catch {
            logger.error("Error in the fetched results controller: \(error.localizedDescription).")
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
    
    private func fetchGroups(delegate: NSFetchedResultsControllerDelegate) {
        do {
            groups?.delegate = delegate
            try groups?.performFetch()
        } catch {
            logger.error("Error in the fetched results controller: \(error.localizedDescription).")
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
    
    private func fetchTeachers(delegate: NSFetchedResultsControllerDelegate) {
        do {
            teachers?.delegate = delegate
            try teachers?.performFetch()
        } catch {
            logger.error("Error in the fetched results controller: \(error.localizedDescription).")
        }
    }
}
