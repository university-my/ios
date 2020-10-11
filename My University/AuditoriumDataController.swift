//
//  AuditoriumDataController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class AuditoriumDataController: EntityDataController {
    
    // MARK: - Init
    
    let network: AuditoriumNetworkController
    
    override init() {
        network = AuditoriumNetworkController()
        
        super.init()
        network.delegate = self
    }
    
    // MARK: - Auditorium
    
    #warning("Add Generic type of `NSManagedObject` to the `ModelKind`")
    var auditorium: AuditoriumEntity? {
        return entity as? AuditoriumEntity
    }
    
    // MARK: - Import
    
    override func importRecords() {
        guard let entity = auditorium else {
            preconditionFailure("Auditorium not found")
        }
        // Start import
        isImporting = true
        network.importRecords(for: entity, by: pairDate)
    }
    
    // MARK: - NSPredicate
    
    override func generatePredicate() -> NSPredicate? {
        guard let auditorium = auditorium else { return nil }
        
        let selectedDate = pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let auditoriumPredicate = NSPredicate(format: "auditorium == %@", auditorium)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [auditoriumPredicate, datePredicate])
        return compoundPredicate
    }
}
