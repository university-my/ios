//
//  UniversityDataController.swift
//  My University
//
//  Created by Yura Voevodin on 17.12.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

final class UniversityDataController {
    
    /// Singleton instance
    public static let shared = UniversityDataController()
    
    // MARK: - Init
    
    // Can't init is singleton
    private init() {}
    
    // MARK: - Import
    
    /// For initiate import of Classrooms, Groups, and Teachers
    private(set) var needImportEntities: Bool = false
    
    func requestToImportEntities() {
        needImportEntities = true
    }
    
    func finishEntitiesImport() {
        needImportEntities = false
    }
}
