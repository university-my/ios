//
//  GroupNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class GroupNetworkController: EntityNetworkController {
    
    func syncRecords(for entity: GroupEntity, by date: Date) {
        guard let object = entity.asStruct() as? Group else {
            preconditionFailure("Invalid entity")
        }
        guard let university = entity.university else {
            preconditionFailure("Invalid university")
        }
        let container = CoreData.default.persistentContainer
        let syncController = Group.RecordsSyncController(
            persistentContainer: container,
            modelID: object.id,
            university: university
        )
        
        // Download records for Group from backend and save to database
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
