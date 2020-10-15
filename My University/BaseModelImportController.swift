//
//  BaseImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

class BaseModelImportController<Kind: ModelKind> {
    
    typealias Model = Kind
    typealias ImportController = ModelImportController<Model>
    
    // MARK: - Properties
    
    internal let importController: ImportController
    internal var completionHandler: ((_ error: Error?) -> ())?
    internal var persistentContainer: NSPersistentContainer
    internal weak var university: UniversityEntity?
    
    // MARK: - Initialization
    
    init?(persistentContainer: NSPersistentContainer, universityID: Int64) {
        guard let importController = ImportController() else { return nil }
        self.importController = importController
        
        self.persistentContainer = persistentContainer
        
        guard let university = UniversityEntity.fetch(id: universityID, context: persistentContainer.viewContext) else { return nil }
        self.university = university
    }
    
    // MARK: - Methods
    
    func importData(_ completion: @escaping ((_ error: Error?) -> ())) {
        guard let universityURL = university?.url else {
            preconditionFailure()
        }
        completionHandler = completion
        
        importController.importData(universityURL: universityURL) { result in
            
            switch result {
            
            case .failure(let error):
                self.completionHandler?(error)
                
            case .success(let data):
                // New context for sync
                let context = self.persistentContainer.newBackgroundContext()
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                context.undoManager = nil
                
                self.sync(from: data, taskContext: context)
            }
        }
    }
    
    /// Delete previous teachers and insert new
    func sync(from data: Data, taskContext: NSManagedObjectContext) {
        
    }
}
