//
//  ClassroomNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class ClassroomNetworkController: EntityNetworkController {
    
    func syncRecords(for classroomEntity: ClassroomEntity, by date: Date) {
        guard let classroom = classroomEntity.asStruct() as? Classroom else {
            preconditionFailure("Invalid classroom")
        }
        guard let university = classroomEntity.university else {
            preconditionFailure("Invalid university")
        }
        let container = CoreData.default.persistentContainer
        let syncController = Classroom.RecordsSyncController(
            persistentContainer: container,
            modelID: classroom.id,
            university: university
        )
        
        // Download records for Group from backend and save to database
        syncController.importRecords(for: date, { [weak self] (result) in
            
            DispatchQueue.main.async {
                
                switch result {
                case .failure(let error):
                    self?.delegate?.didImportRecords(for: classroom, error)
                case .success:
                    self?.delegate?.didImportRecords(for: classroom, nil)
                }
            }
        })
    }
}
