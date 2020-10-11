//
//  GroupNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class GroupNetworkController: EntityNetworkController {
    
    private var importManager: Record.ImportForGroup?
    
    func importRecords(for groupEntity: GroupEntity, by date: Date) {
        guard let group = groupEntity.asStruct() else {
            preconditionFailure("Invalid group")
        }
        guard let university = groupEntity.university else {
            preconditionFailure("Invalid university")
        }
        // Init new import manager
        let container = CoreData.default.persistentContainer
        importManager = Record.ImportForGroup(persistentContainer: container, modelID: groupEntity.id, universityURL: university.url ?? "")
        
        // Download records for Group from backend and save to database.
        importManager?.importRecords(for: date, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(for: group, error)
            }
        })
    }
}
