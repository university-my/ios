//
//  GroupDataController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

protocol GroupDataControllerDelegate: class {
    func groupDataController(didImportRecordsFor group: Group, _ error: Error?)
    func groupDataController(didBuildSectionsFor group: Group)
}

class GroupDataController {
    
    // MARK: - Init
    
    weak var delegate: GroupDataControllerDelegate?
    let network: GroupNetworkController
    
    init() {
        network = GroupNetworkController()
        network.delegate = self
    }
    
    // MARK: - Data
    
    func loadData() {
        guard let groupEntity = group, let group = groupEntity.asStruct() else {
            preconditionFailure("Group not found")
        }
        updateDatePredicate()
        fetchRecords()
        buildSections()
        delegate?.groupDataController(didBuildSectionsFor: group)
    }
    
    func importRecordsIfNeeded() {
        guard let group = group else {
            preconditionFailure("Group not found")
        }
        if needToImportRecords {
            network.importRecords(for: group, by: pairDate)
        }
    }
    
    var needToImportRecords: Bool {
        fetchedRecords.isEmpty
    }
    
    // MARK: - Group
    
    private(set) var group: GroupEntity?
    private(set) var groupID: Int64?
    
    func fetchGroup(with id: Int64) {
        groupID = id
        group = GroupEntity.fetch(id: id, context: CoreData.default.viewContext)
    }
    
    // MARK: - Records
    
    private func fetchRecords() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    private var fetchedRecords: [RecordEntity] {
        fetchedResultsController?.fetchedObjects ?? []
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
    
    // MARK: - Sections
    
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
    
    private(set) var pairDate = Date()
    
    func changePairDate(to newDate: Date) {
        pairDate = newDate
        loadData()
        importRecordsIfNeeded()
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
    
    private func generatePredicate() -> NSPredicate? {
        guard let group = group else { return nil }
        
        let selectedDate = pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let groupsPredicate = NSPredicate(format: "ANY groups == %@", group)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupsPredicate, datePredicate])
        return compoundPredicate
    }
    
    func updateDatePredicate() {
        fetchedResultsController?.fetchRequest.predicate = generatePredicate()
    }
    
    // MARK: - Favorite
    
    func toggleFavorite<T: FavoriteEntityProtocol>(for entity: T) {
        entity.toggleFavorite()
        CoreData.default.saveContext()
    }
}

// MARK: - GroupNetworkControllerDelegate

extension GroupDataController: GroupNetworkControllerDelegate {
    
    func didImportRecords(for group: Group, _ error: Error?) {
        delegate?.groupDataController(didImportRecordsFor: group, error)
        updateDatePredicate()
        fetchRecords()
        buildSections()
        delegate?.groupDataController(didBuildSectionsFor: group)
    }
}
