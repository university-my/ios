//
//  TeacherDataController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class TeacherDataController: EntityDataController {
    
    // MARK: - Init
    
    let network: TeacherNetworkController
    
    override init() {
        network = TeacherNetworkController()
        
        super.init()
        network.delegate = self
    }
    
    // MARK: - Teacher
    
    var teacher: TeacherEntity? {
        return entity as? TeacherEntity
    }
    
    // MARK: - Import
    
    override func importRecords() {
        guard let entity = teacher else {
            preconditionFailure("Teacher not found")
        }
        // Start import
        isImporting = true
        network.syncRecords(for: entity, by: pairDate)
    }
    
    // MARK: - NSPredicate
    
    override func generatePredicate() -> NSPredicate? {
        guard let teacher = teacher else { return nil }
        let selectedDate = pairDate
        
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let teacherPredicate = NSPredicate(format: "teacher == %@", teacher)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [teacherPredicate, datePredicate])
        return compoundPredicate
    }
}
