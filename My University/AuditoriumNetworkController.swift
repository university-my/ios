//
//  AuditoriumNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class AuditoriumNetworkController: EntityNetworkController<Auditorium> {
    
    private var importManager: Record.ImportForAuditorium?
    
    func importRecords(for auditoriumEntity: AuditoriumEntity, by date: Date) {
        guard let auditorium = auditoriumEntity.asStruct() else {
            preconditionFailure("Invalid auditorium")
        }
        guard let universityURL = auditoriumEntity.university?.url else {
            preconditionFailure("Invalid university")
        }
        // Init new import manager
        let container = CoreData.default.persistentContainer
        importManager = Record.ImportForAuditorium(persistentContainer: container, auditoriumID: auditorium.id, universityURL: universityURL)
        
        // Download records for Group from backend and save to database.
        importManager?.importRecords(for: date, { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.delegate?.didImportRecords(for: auditorium, error)
            }
        })
    }
}
