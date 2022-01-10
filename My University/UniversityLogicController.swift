//
//  UniversityLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 30.09.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol UniversityLogicControllerDelegate: AnyObject {
    func logicDidUpdateAllEntities()
    func logicDidLoadAllEntities()
}

extension UniversityViewController {
    
    final class UniversityLogicController {
        
        weak var delegate: UniversityLogicControllerDelegate?
        
        // MARK: - Configure
        
        private(set) weak var dataSource: UniversityDataSource?
        
        func configure(delegate: UniversityLogicControllerDelegate, dataSource: UniversityDataSource, universityID: Int64) {
            self.dataSource = dataSource
            
            // Init all data sources
            groups = GroupsDataSource(universityID: universityID)
            teachers = TeacherDataSource(universityID: universityID)
            classrooms = ClassroomDataSource(universityID: universityID)
        }
        
        func updateAllEntities() {
            // Start from groups,
            // And update classrooms and teachers
            updateGroups()
        }
        
        
        func importAllEntities() {
            // Start from groups,
            // And import classrooms and teachers
            loadGroups()
        }
        
        // MARK: - Groups
        
        private var groups: GroupsDataSource?
        
        var shouldImportGroups: Bool {
            dataSource?.university?.showGroups ?? false
        }
        
        private func updateGroups() {
            // Check, if groups is present in this university
            guard shouldImportGroups else {
                // Continue to teachers
                updateTeachers()
                return
            }
            
            guard let dataSource = groups else { return }
            dataSource.importGroups { _ in
                self.updateTeachers()
            }
        }
        
        private func loadGroups() {
            guard shouldImportGroups else {
                loadTeachers()
                return
            }
            
            guard let dataSource = groups else { return }
            dataSource.performFetch()
            let groups = dataSource.fetchedResultsController?.fetchedObjects ?? []
            
            if groups.isEmpty {
                
                dataSource.importGroups { _ in
                    self.loadTeachers()
                }
            } else {
                loadTeachers()
            }
        }
        
        // MARK: - Teachers
        
        private var teachers: TeacherDataSource?
        
        var shouldImportTeachers: Bool {
            dataSource?.university?.showTeachers ?? false
        }
        
        private func updateTeachers() {
            // Check, if teacher is present in this university
            guard shouldImportTeachers else {
                // Continue to classrooms
                updateClassrooms()
                return
            }
            
            guard let dataSource = teachers else { return }
            dataSource.importTeachers { _ in
                self.updateClassrooms()
            }
        }
        
        private func loadTeachers() {
            guard shouldImportTeachers else {
                loadClassrooms()
                return
            }
            guard let dataSource = teachers else { return }
            dataSource.performFetch()
            
            let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
            if teachers.isEmpty {
                
                dataSource.importTeachers { _ in
                    self.loadClassrooms()
                }
            } else {
                loadClassrooms()
            }
        }
        
        // MARK: - Classrooms
        
        private var classrooms: ClassroomDataSource?
        
        var shouldImportClassrooms: Bool {
            dataSource?.university?.showClassrooms ?? false
        }
        
        private func updateClassrooms() {
            guard shouldImportClassrooms else {
                delegate?.logicDidUpdateAllEntities()
                return
            }
            
            guard let dataSource = classrooms else { return }
            dataSource.importClassrooms { _ in
                self.delegate?.logicDidUpdateAllEntities()
            }
        }
        
        private func loadClassrooms() {
            guard shouldImportClassrooms else {
                delegate?.logicDidLoadAllEntities()
                return
            }
            guard let dataSource = classrooms else { return }
            dataSource.performFetch()
            
            let classrooms = dataSource.fetchedResultsController?.fetchedObjects ?? []
            if classrooms.isEmpty {
                
                dataSource.importClassrooms { _ in
                    self.delegate?.logicDidLoadAllEntities()
                }
            } else {
                delegate?.logicDidLoadAllEntities()
            }
        }
        
        // MARK: - What's New
        
        private var latestVersionKey: String {
            UserDefaultsKeys.latestVersionForNewFeaturesKey
        }
        
        func needToPresentWhatsNew() -> Bool {
            guard let currentVersion = Bundle.main.shortVersion else { return false }
            return needToPresentWhatsNew(for: currentVersion)
        }
        
        func needToPresentWhatsNew(for requestedVersion: String) -> Bool {
            let latestSavedVersion = UserDefaults.standard.string(forKey: latestVersionKey)
            
            // Don't show again for the same version
            if requestedVersion == latestSavedVersion {
                return false
            }
            
            // Show only for selected version
            return requestedVersion == "1.7.6"
        }
        
        func updateLastVersionForNewFeatures() {
            guard let currentVersion = Bundle.main.shortVersion else { return }
            updateLatestVersionForNewFeatures(to: currentVersion)
        }
        
        func updateLatestVersionForNewFeatures(to version: String)  {
            UserDefaults.standard.set(version, forKey: latestVersionKey)
        }
        
        func resetLatestVersionForNewFeatures() {
            UserDefaults.standard.removeObject(forKey: latestVersionKey)
        }
        
    }
    
}
