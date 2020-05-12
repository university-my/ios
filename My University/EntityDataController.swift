//
//  EntityDataController.swift
//  My University
//
//  Created by Yura Voevodin on 02.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

protocol EntityDataControllerDelegate: class {
    
    func entityDataController(didImportRecordsFor structure: EntityRepresentable, _ error: Error?)
    func entityDataController(didBuildSectionsFor structure: EntityRepresentable)
}

/// Base class for data controllers of Auditorium, Group, Teacher
class EntityDataController: EntityDataControllerProtocol {
    
    weak var delegate: EntityDataControllerDelegate?
    
    // MARK: - Import
    
    /// `true` while importing records and building sections
    var isImporting = false
    
    func importRecords() {
        // Override in subclasses
    }
    
    // MARK: - Records
    
    var needToImportRecords: Bool {
        fetchedRecords.isEmpty
    }
    
    var fetchedRecords: [RecordEntity] {
        fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchRecords() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    func record(at indexPath: IndexPath) -> Record? {
        let section =  sections[safe: indexPath.section]
        switch section?.kind {
            
        case .none:
            return nil
            
        case .noRecords:
            return nil
            
        case .records(let records, _):
            return records[safe: indexPath.item]
        }
    }
    
    // MARK: - Entity
    
    var entity: NSManagedObject?
    
    // MARK: - Sections
    
    func updateSections() {
        guard let entity = entity as? StructRepresentable else {
            preconditionFailure("Entity not found")
        }
        guard let structure = entity.asStruct() else {
            preconditionFailure("Struct not found")
        }
        buildSections()
        delegate?.entityDataController(didBuildSectionsFor: structure)
    }
    
    struct Section {
        
        enum Kind {
            case noRecords
            case records(records: [Record], title: String)
        }
        
        var kind: Kind
        
        var title: String? {
            switch kind {
            case .noRecords:
                return nil
            case .records(_, let title):
                return title
            }
        }
    }
    
    var sections: [Section] = []
    
    func buildSections() {
        var newSections: [Section] = []
        
        if fetchedRecords.isEmpty {
            newSections = [Section(kind: .noRecords)]
        } else {
            newSections.append(contentsOf: buildRecordsSections(from: fetchedResultsController))
        }
        sections = newSections
    }
    
    /// `[RecordEntity]` to `[Section]`
    func buildRecordsSections(from fetchedResultsController: NSFetchedResultsController<RecordEntity>?) -> [Section] {
        var sections: [Section] = []
        guard let controller = fetchedResultsController else { return [] }
        
        controller.sections?.forEach({ (section) in
            if let fetchedRecords = section.objects as? [RecordEntity] {
                
                // Title
                let title = sectionName(from: fetchedRecords.first)
                
                // Records
                let records = fetchedRecords.toStructs()
                
                let section = Section(kind: .records(records: records, title: title))
                sections.append(section)
            }
        })
        return sections
    }
    
    private func sectionName(from record: RecordEntity?) -> String {
        var sectionName = ""
        if let name = record?.pairName {
            sectionName = name
        }
        if let time = record?.time {
            sectionName += " (\(time))"
        }
        return sectionName
    }
    
    // MARK: - Date
    
    var pairDate = Date()
    
    func changePairDate(to newDate: Date) {
        pairDate = newDate
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<RecordEntity>? = {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        let pairName = NSSortDescriptor(key: #keyPath(RecordEntity.pairName), ascending: true)
        let date = NSSortDescriptor(key: #keyPath(RecordEntity.date), ascending: true)
        
        request.sortDescriptors = [pairName, date]
        request.predicate = generatePredicate()
        request.fetchBatchSize = 20
        
        let context = CoreData.default.viewContext
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.pairName), cacheName: nil)
        return controller
    }()
    
    /// Override in subclasses
    func generatePredicate() -> NSPredicate? {
        return nil
    }
    
    func updateDatePredicate() {
        fetchedResultsController?.fetchRequest.predicate = generatePredicate()
    }
    
    // MARK: - Favorite
    
    func toggleFavorite<T: FavoriteEntityProtocol>(for entity: T) {
        entity.toggleFavorite()
        CoreData.default.saveContext()
    }
    
    // MARK: - Share URL
    
    func shareURL(for entity: EntityProtocol?) -> URL? {
        guard let entity = entity else { return nil }
        return entity.shareURL(for: pairDate)
    }
}

// MARK: - EntityNetworkControllerDelegate

extension EntityDataController: EntityNetworkControllerDelegate {
    
    func didImportRecords(for structure: EntityRepresentable, _ error: Error?) {
        delegate?.entityDataController(didImportRecordsFor: structure, error)
        updateDatePredicate()
        fetchRecords()
        buildSections()
        
        // Finish 🏁
        isImporting = false
        delegate?.entityDataController(didBuildSectionsFor: structure)
    }
}
