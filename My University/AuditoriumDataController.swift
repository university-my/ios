//
//  ClassroomDataController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class ClassroomDataController: EntityDataController {
    
    // MARK: - Init
    
    let network: AuditoriumNetworkController
    
    override init() {
        network = AuditoriumNetworkController()
        
        super.init()
        network.delegate = self
    }
    
    // MARK: - Classroom
    
    var classroom: ClassroomEntity? {
        return entity as? ClassroomEntity
    }
    
    // MARK: - Import
    
    override func importRecords() {
        guard let entity = classroom else {
            preconditionFailure("Classroom not found")
        }
        // Start import
        isImporting = true
        network.importRecords(for: entity, by: pairDate)
    }
    
    // MARK: - NSPredicate
    
    override func generatePredicate() -> NSPredicate? {
        guard let classroom = classroom else { return nil }
        
        let selectedDate = pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let classroomPredicate = NSPredicate(format: "classroom == %@", classroom)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [classroomPredicate, datePredicate])
        return compoundPredicate
    }
}
