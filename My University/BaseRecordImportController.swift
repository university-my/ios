//
//  BaseRecordImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

class BaseRecordImportController<Model: ModelKind> {
    
    typealias NetworkClient = Record.NetworkClient<Model>
    
    // MARK: - Properties
    
    internal let networkClient: NetworkClient
    internal var completionHandler: ((_ error: Error?) -> ())?
    internal let modelID: Int64
    internal let universityURL: String
    
    internal let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    
    init?(persistentContainer: NSPersistentContainer, modelID: Int64, universityURL: String) {
        self.modelID = modelID
        self.universityURL = universityURL
        self.persistentContainer = persistentContainer
        networkClient = NetworkClient()
    }
    
    // MARK: - Methods
    
    func importRecords(for date: Date, _ completion: @escaping ((_ error: Error?) -> ())) {
        completionHandler = completion
        
        let dateString = DateFormatter.short.string(from: date)
        let params = Record.RequestParameters(id: modelID, university: universityURL, date: dateString)
        
        networkClient.loadRecords(params) { (result) in
            
            switch result {
            
            case .failure(let error):
                self.completionHandler?(error)
                
            case .success(let list):
                // New context for sync
                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil
                
                self.sync(list.records, taskContext: taskContext)
            }
        }
    }
    
    func sync(_ records: [Record.CodingData], taskContext: NSManagedObjectContext) {
        
    }
}
