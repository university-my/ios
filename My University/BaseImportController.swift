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
}
