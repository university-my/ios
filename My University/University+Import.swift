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
        
        // MARK: - Properties
        
        private let networkClient: NetworkClient<[University.CodingData]>
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
            
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            networkClient.load(url: University.Endpoints.allUniversities.url, decoder: decoder) { (result) in
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
                        map(universityFromServer, to: university)
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
        
        private func insert(_ codingData: University.CodingData, context: NSManagedObjectContext) {
            let entity = UniversityEntity(context: context)
            entity.id = codingData.serverID
            
            map(codingData, to: entity)
        }
        
        private func map(_ codingData: University.CodingData, to entity: UniversityEntity) {
            entity.fullName = codingData.fullName
            entity.shortName = codingData.shortName
            entity.url = codingData.url
            entity.isHidden = codingData.isHidden
            entity.isBeta = codingData.isBeta
            entity.pictureDark = codingData.pictureDark
            entity.pictureWhite = codingData.pictureWhite
            entity.showClassrooms = codingData.showClassrooms
            entity.showGroups = codingData.showGroups
            entity.showTeachers = codingData.showTeachers
        }
    }
}
