//
//  GroupNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

protocol GroupNetworkControllerDelegate: class {
    func didImportRecords(for group: Group, _ error: Error?)
}

class GroupNetworkController {
    
    weak var delegate: GroupNetworkControllerDelegate?
    
    // MARK: - Import Records
    
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
        importManager = Record.ImportForGroup(persistentContainer: container, group: groupEntity, university: university)
        
        // Download records for Group from backend and save to database.
        importManager?.importRecords(for: date, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(for: group, error)
            }
        })
    }
}
