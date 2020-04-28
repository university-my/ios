//
//  GroupDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

protocol GroupDataSourceDelegate: class {
    func didImportRecords(_ error: Error?)
}

class GroupDataSource: RecordsDataSource {
    
    weak var delegate: GroupDataSourceDelegate?
    
    func rebuild() {
        var newSections: [Section] = []
        
        if fetchedRecords.isEmpty {
            newSections = [Section(kind: .noRecords)]
        } else {
            newSections.append(contentsOf: buildRecordsSections(from: fetchedResultsController))
        }
        sections = newSections
    }
    
    var fetchedRecords: [RecordEntity] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    // MARK: - Init
    
    init(groupID: Int64) {
        self.groupID = groupID
    }
 
    // MARK: - Sections
    
    private(set) var sectionsTitles: [String] = []
    
    // MARK: - Group
    
    private(set) var group: GroupEntity?
    var groupID: Int64
    
    func fetchGroup() {
        group = GroupEntity.fetch(id: groupID, context: viewContext)
    }
    
    func groupURL() -> String? {
        guard let group = group else { return nil }
        guard let universityURL = group.university?.url else { return nil }
        guard let slug = group.slug else { return nil }
        let dateString = DateFormatter.short.string(from: pairDate)
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/groups/\(slug)?pair_date=\(dateString)"
        return url
    }
    
    // MARK: - Import Records
    
    private var importManager: Record.ImportForGroup?
    
    func importRecords() {
        let container = persistentContainer
        
        guard let group = group else { return }
        guard let university = group.university else { return }
        
        // Download records for Group from backend and save to database.
        importManager = Record.ImportForGroup(persistentContainer: container, group: group, university: university)
        importManager?.importRecords(for: pairDate, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(error)
            }
        })
    }
    
    // MARK: - Date
    
    var pairDate = Date()
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<RecordEntity>? = {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        let pairName = NSSortDescriptor(key: #keyPath(RecordEntity.pairName), ascending: true)
        let date = NSSortDescriptor(key: #keyPath(RecordEntity.date), ascending: true)
        
        request.sortDescriptors = [pairName, date]
        request.predicate = generatePredicate()
        request.fetchBatchSize = 20
        
        let context = viewContext
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.pairName), cacheName: nil)
        return controller
    }()
    
    func fetchRecords() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
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
}
