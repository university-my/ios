//
//  TeachersLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 10.03.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

extension TeachersTableViewController {
    
    final class TeachersLogicController {
        
        // MARK: - Setup
     
        private var universityID: Int64?
        private var dataSource: TeacherDataSource?
        
        func update(with universityID: Int64, dataSource: TeacherDataSource?) {
            self.universityID = universityID
            self.dataSource = dataSource
        }
        
        // MARK: - Update
        
        /// Check last updated date of teachers
        func needToUpdateTeachers() -> Bool {
            guard let id = universityID else {
                return false
            }
            let lastSynchronisation = UpdateHelper.lastUpdated(for: id, type: .teacher)
            return UpdateHelper.needToUpdate(from: lastSynchronisation)
        }
        
        func needToImportTeachers() -> Bool {
            dataSource?.performFetch()
            let teachers = dataSource?.fetchedResultsController?.fetchedObjects ?? []
            
            if teachers.isEmpty {
                return true
            } else if needToUpdateTeachers() {
                // Update teachers once in a day
                return true
            } else {
                return false
            }
        }
        
        func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
            guard let id = universityID else {
                return
            }
            dataSource?.importTeachers { (error) in
                if error == nil {
                    UpdateHelper.updated(at: Date(), universityID: id, type: .teacher)
                }
                completion(error)
            }
        }
    }
}
