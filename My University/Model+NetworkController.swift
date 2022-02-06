//
//  Model+NetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 18.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol ModelNetworkControllerDelegate: AnyObject {
    func didImportRecords(for entity: CoreDataFetchProtocol & CoreDataEntityProtocol, _ error: Error?)
}

extension Model {
    
    class NetworkController {
        
        weak var delegate: ModelNetworkControllerDelegate?
        lazy var decoder = JSONDecoder()
        
        func syncRecords(for entity: CoreDataEntity, by date: Date) {
            guard let university = entity.university else {
                preconditionFailure("Invalid university")
            }
            let container = CoreData.shared.persistentContainer
            let syncController = Model.RecordsSyncController(
                persistentContainer: container,
                modelID: entity.id,
                university: university
            )
            
            // Download records for entity from backend and save to database
            syncController.importRecords(for: date, decoder: decoder, { [weak self] (result) in
                
                DispatchQueue.main.async {
                    
                    switch result {
                    case .failure(let error):
                        self?.delegate?.didImportRecords(for: entity, error)
                    case .success:
                        self?.delegate?.didImportRecords(for: entity, nil)
                    }
                }
            })
        }
    }
}
