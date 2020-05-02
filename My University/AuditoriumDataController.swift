//
//  AuditoriumDataController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class AuditoriumDataController: EntityDataController<Auditorium> {
    
    // MARK: - Init
    
    let network: AuditoriumNetworkController
    
    override init() {
        network = AuditoriumNetworkController()
        
        super.init()
        network.delegate = self
    }
    
    // MARK: - Data
    
    override func loadData() {
        guard let entity = auditorium,
            let auditorium = entity.asStruct() else {
                preconditionFailure("Auditorium not found")
        }
        updateDatePredicate()
        fetchRecords()
        buildSections()
        delegate?.entityDataController(didBuildSectionsFor: auditorium)
    }
    
    // MARK: - Import
    
    func importRecords() {
        guard let entity = auditorium else {
            preconditionFailure("Auditorium not found")
        }
        // Start import
        isImporting = true
        network.importRecords(for: entity, by: pairDate)
    }
    
    // MARK: - Auditorium
    
    private(set) var auditorium: AuditoriumEntity?
    private(set) var auditoriumID: Int64?
    
    func fetchAuditorium(with id: Int64) {
        auditoriumID = id
        auditorium = AuditoriumEntity.fetch(id: id, context: CoreData.default.viewContext)
    }
    
    // MARK: - NSPredicate
    
    override func generatePredicate() -> NSPredicate? {
        guard let auditorium = auditorium else { return nil }
        
        let selectedDate = pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let groupsPredicate = NSPredicate(format: "auditorium == %@", auditorium)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupsPredicate, datePredicate])
        return compoundPredicate
    }
}
