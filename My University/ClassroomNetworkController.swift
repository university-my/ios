//
//  ClassroomNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class ClassroomNetworkController: EntityNetworkController {
    
    private var importManager: Record.ImportForClassroom?
    
    func importRecords(for classroomEntity: ClassroomEntity, by date: Date) {
        guard let classroom = classroomEntity.asStruct() as? Classroom else {
            preconditionFailure("Invalid classroom")
        }
        guard let universityURL = classroomEntity.university?.url else {
            preconditionFailure("Invalid university")
        }
        // Init new import manager
        let container = CoreData.default.persistentContainer
        importManager = Record.ImportForClassroom(persistentContainer: container, modelID: classroom.id, universityURL: universityURL)
        
        // Download records for Group from backend and save to database.
        importManager?.importRecords(for: date, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(for: classroom, error)
            }
        })
    }
}
