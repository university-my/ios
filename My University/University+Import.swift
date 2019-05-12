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
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let persistentContainer: NSPersistentContainer
        
        // MARK: - Init
        
        init?(persistentContainer: NSPersistentContainer) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("universities.json") else { return nil }
            
            self.cacheFile = cacheFile
            self.persistentContainer = persistentContainer
            networkClient = NetworkClient(cacheFile: self.cacheFile)
        }
        
        // MARK: - Methods
        
        func importUniversities(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadUniversities { (error) in
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.serializeJSON()
                }
            }
        }
        
        private func serializeJSON() {
            guard let stream = InputStream(url: cacheFile) else {
                completionHandler?(nil)
                return
            }
            stream.open()
            
            defer {
                stream.close()
            }
            do {
                let object = try JSONSerialization.jsonObject(with: stream, options: []) as? [Any]
                if let json = object as? [[String: Any]] {
                    // New context for sync.
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    syncUniversities(from: json, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        private func syncUniversities(from json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                // Parse universities.
                let parsedUniversities = json.compactMap { University($0) }
                
                // IDs to fetch
                let ids = parsedUniversities.map({ university in
                    return university.serverID
                })
                
                // Universities to update
                let toUpdate = UniversityEntity.fetch(ids, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ university in
                    return university.id
                })
                
                // Find universities to insert
                let toInsert = parsedUniversities.filter({ university in
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
                    if let universityFromServer = parsedUniversities.first(where: { (parsedUniversity) -> Bool in
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
        
        private func insert(_ parsedUniversity: University, context: NSManagedObjectContext) {
            let universityEntity = UniversityEntity(context: context)
            universityEntity.id = parsedUniversity.serverID
            universityEntity.fullName = parsedUniversity.fullName
            universityEntity.shortName = parsedUniversity.shortName
            universityEntity.url = parsedUniversity.url
        }
    }
}
