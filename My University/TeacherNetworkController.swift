//
//  TeacherNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class TeacherNetworkController: EntityNetworkController {
    
    #warning("Make it as single class")
    
    func syncRecords(for entity: TeacherEntity, by date: Date) {
        guard let object = entity.asStruct() as? Teacher else {
            preconditionFailure("Invalid entity")
        }
        guard let university = entity.university else {
            preconditionFailure("Invalid university")
        }
        let container = CoreData.default.persistentContainer
        let syncController = Teacher.RecordsSyncController(
            persistentContainer: container,
            modelID: object.id,
            university: university
        )
        
        // Download records for Teacher from backend and save to database
        syncController.importRecords(for: date, { [weak self] (result) in
            
            DispatchQueue.main.async {
                
                switch result {
                case .failure(let error):
                    self?.delegate?.didImportRecords(for: object, error)
                case .success:
                    self?.delegate?.didImportRecords(for: object, nil)
                }
            }
        })
    }
}
