//
//  University+Import.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData

extension University {
    
    class Import {
        
        typealias NetworkClient = University.NetworkClient
        
        // MARK: - Properties
        
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let persistentContainer: NSPersistentContainer
        
        // MARK: - Init
        
        init?(persistentContainer: NSPersistentContainer) {
            self.persistentContainer = persistentContainer
            networkClient = NetworkClient()
        }
        
        // MARK: - Methods
        
        func importUniversities(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.loadUniversities { (result) in
                switch result {
                
                case .failure(let error):
                    self.completionHandler?(error)
                    
                case .success(let universities):
                    // New context for sync
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    self.sync(universities, in: taskContext)
                }
            }
        }
        
        private func sync(_ universities: [University.CodingData], in taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                // IDs to fetch
                let ids = universities.map({ university in
                    return university.serverID
                })
                
                // Universities to update
                let toUpdate = UniversityEntity.fetch(ids, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ university in
                    return university.id
                })
                
                // Find universities to insert
                let toInsert = universities.filter({ university in
                    return (idsToUpdate.contains(university.serverID) == false)
                })
                
                // Now find universities to delete
                let allUniversities = UniversityEntity.fetchAll(context: taskContext)
                let toDelete = allUniversities.filter({ university in
                    return (ids.contains(university.id) == false)
                })
                
                // 1. Delete
                for university in toDelete {
                    taskContext.delete(university)
                }
                
                // 2. Update
                for university in toUpdate {
                    if let universityFromServer = universities.first(where: { (parsedUniversity) -> Bool in
                        return university.id == parsedUniversity.serverID
                    }) {
                        university.fullName = universityFromServer.fullName
                        university.shortName = universityFromServer.shortName
                        university.url = universityFromServer.url
                    }
                }
                
                // 3. Insert
                for university in toInsert {
                    self.insert(university, context: taskContext)
                }
                
                // Finishing import. Save context.
                if taskContext.hasChanges {
                    do {
                        try taskContext.save()
                    } catch {
                        self.completionHandler?(error)
                    }
                }
                
                // Reset the context to clean up the cache and low the memory footprint.
                taskContext.reset()

                // Finish.
                self.completionHandler?(nil)
            }
        }
        
        private func insert(_ parsedUniversity: University.CodingData, context: NSManagedObjectContext) {
            let universityEntity = UniversityEntity(context: context)
            universityEntity.id = parsedUniversity.serverID
            universityEntity.fullName = parsedUniversity.fullName
            universityEntity.shortName = parsedUniversity.shortName
            universityEntity.url = parsedUniversity.url
        }
    }
}
