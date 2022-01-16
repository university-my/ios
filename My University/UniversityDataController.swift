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
    
    // MARK: - Update
    
    /// For initiate import of Classrooms, Groups, and Teachers
    private(set) var entitiesUpdateNeeded: Bool = false
    
    func requestEntitiesUpdate() {
        entitiesUpdateNeeded = true
    }
    
    func entitiesUpdateCompleted() {
        entitiesUpdateNeeded = false
    }
}
