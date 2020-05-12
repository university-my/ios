//
//  TeacherNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class TeacherNetworkController: EntityNetworkController {
    
    private var importManager: Record.ImportForTeacher?
    
    func importRecords(for entity: TeacherEntity, date: Date) {
        guard let university = entity.university else {
            preconditionFailure("Invalid university")
        }
        guard let teacher = entity.asStruct() as? Teacher else {
            preconditionFailure("Invalid teacher")
        }
        // Init new import manager
        let container = CoreData.default.persistentContainer
        importManager = Record.ImportForTeacher(persistentContainer: container, teacher: entity, university: university)
        
        // Download records for Teacher from backend and save to database.
        importManager?.importRecords(for: date, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(for: teacher, error)
            }
        })
    }
}
