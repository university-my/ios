//
//  Model+DataController.swift
//  My University
//
//  Created by Yura Voevodin on 18.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData
import os

protocol ModelDataControllerDelegate: AnyObject {
    
    func entityDataController(didImportRecordsFor structure: EntityRepresentable, _ error: Error?)
    func entityDataController(didBuildSectionsFor structure: EntityRepresentable)
}

extension Model {
    
    class DataController  {
        
        // MARK: - Properties
        
        private let logger = Logger(subsystem: Bundle.identifier, category: "Model.DataController")
        private let networkController: NetworkController
        weak var delegate: ModelDataControllerDelegate?
        
        // MARK: - Init
        
        init() {
            networkController = NetworkController()
            networkController.delegate = self
        }
        
        // MARK: - Import
        
        /// `true` while importing records and building sections
        private(set) var isImporting = false
        
        func importRecords() {
            guard let entity = entity else {
                preconditionFailure("Entity not found")
            }
            // Start import
            isImporting = true
            networkController.syncRecords(for: entity, by: pairDate)
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
                logger.error("Error in the fetched results controller: \(error.localizedDescription).")
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
        
        var entity: CoreDataEntity?
        
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
            
            let context = CoreData.shared.viewContext
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.pairName), cacheName: nil)
            return controller
        }()
        
        func generatePredicate() -> NSPredicate? {
            guard let entity = entity else { return nil }
            let selectedDate = pairDate
            
            let startOfDay = selectedDate.startOfDay as NSDate
            let endOfDay = selectedDate.endOfDay as NSDate
            
            let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
            let teacherPredicate = Model.fetchRequestPredicate(for: entity)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [teacherPredicate, datePredicate])
            return compoundPredicate
        }
        
        func updateDatePredicate() {
            fetchedResultsController?.fetchRequest.predicate = generatePredicate()
        }
        
        // MARK: - Favorite
        
        func toggleFavorites() {
            entity?.isFavorite.toggle()
            CoreData.shared.saveContext()
        }
        
        func removeFromFavorites() {
            entity?.isFavorite = false
            CoreData.shared.saveContext()
        }
        
        // MARK: - Share URL
        
        func shareURL(for entity: CoreDataEntityProtocol?) -> URL? {
            guard let entity = entity else { return nil }
            return entity.shareURL(for: pairDate)
        }
    }
}

// MARK: - ModelNetworkControllerDelegate

extension Model.DataController: ModelNetworkControllerDelegate {
    
    func didImportRecords(for entity: CoreDataEntityProtocol & CoreDataFetchable, _ error: Error?) {
        guard let model = entity as? StructRepresentable else {
            preconditionFailure()
        }
        guard let structure = model.asStruct() else {
            preconditionFailure()
        }
        delegate?.entityDataController(didImportRecordsFor: structure, error)
        updateDatePredicate()
        fetchRecords()
        buildSections()
        
        // Finish 🏁
        isImporting = false
        delegate?.entityDataController(didBuildSectionsFor: structure)
    }
}
