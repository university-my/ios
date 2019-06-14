//
//  Auditorium+Import.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Auditorium {
    
    class Import {
        
        typealias NetworkClient = Auditorium.NetworkClient
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private var persistentContainer: NSPersistentContainer
        private weak var university: UniversityEntity?
        
        // MARK: - Initialization
        
        init?(persistentContainer: NSPersistentContainer, universityID: Int64) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("auditoriums.json") else { return nil }
            
            self.cacheFile = cacheFile
            networkClient = NetworkClient(cacheFile: self.cacheFile)
            
            self.persistentContainer = persistentContainer
            
            guard let university = UniversityEntity.fetch(id: universityID, context: persistentContainer.viewContext) else { return nil }
            self.university = university
        }
        
        // MARK: - Methods
        
        func importAuditoriums(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadAuditoriums(universityURL: university?.url ?? "") { (error) in
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
                    
                    syncAuditoriums(from: json, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        /// Delete previous groups and insert new
        private func syncAuditoriums(from json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                // University in current context
                guard let universityObjectID = university?.objectID else {
                    self.completionHandler?(nil)
                    return
                }
                guard let universityInContext = taskContext.object(with: universityObjectID) as? UniversityEntity else {
                    self.completionHandler?(nil)
                    return
                }
                
                // Parse auditoriums.
                let parsedAuditoriums = json.compactMap { Auditorium($0) }
                
                // Auditoriums to update
                let toUpdate = AuditoriumEntity.fetch(parsedAuditoriums, university: universityInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.compactMap({ auditorium in
                    return auditorium.slug
                })
                
                // Find auditoriums to insert
                let toInsert = parsedAuditoriums.filter({ auditorium in
                    return (idsToUpdate.contains(auditorium.slug) == false)
                })
                
                // IDs
                let slugs = parsedAuditoriums.map({ auditorium in
                    return auditorium.slug
                })
                
                // Now find auditoriums to delete
                let allAuditoriums = AuditoriumEntity.fetchAll(university: universityInContext, context: taskContext)
                let toDelete = allAuditoriums.filter({ auditorium in
                  if let slug = auditorium.slug {
                    return (slugs.contains(slug) == false)
                  } else {
                    return true
                  }
                })
                
                // 1. Delete
                for auditorium in toDelete {
                    taskContext.delete(auditorium)
                }
                
                // 2. Update
                for auditorium in toUpdate {
                    if let auditoriumFromServer = parsedAuditoriums.first(where: { (parsedAuditorium) -> Bool in
                        return parsedAuditorium.slug == auditorium.slug
                    }) {
                        // Update name if changed
                        if auditoriumFromServer.name != auditorium.name {
                            auditorium.name = auditoriumFromServer.name
                            if let firstCharacter = auditoriumFromServer.name.first {
                                auditorium.firstSymbol = String(firstCharacter).uppercased()
                            } else {
                                auditorium.firstSymbol = ""
                            }
                        }
                        
                        if (auditorium.records?.count ?? 0) > 0 {
                            // Delete all related records
                            // Because Auditorium can be changed to another one.
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                            
                            fetchRequest.predicate = NSPredicate(format: "auditorium == %@", auditorium)
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                            deleteRequest.resultType = .resultTypeObjectIDs
                            
                            do {
                                let result = try taskContext.execute(deleteRequest) as? NSBatchDeleteResult
                                if let objectIDArray = result?.result as? [NSManagedObjectID] {
                                    let changes = [NSDeletedObjectsKey: objectIDArray]
                                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
                                }
                            } catch {
                                completionHandler?(error)
                            }
                        }
                    }
                }
                
                // 3. Insert
                for auditorium in toInsert {
                    self.insert(auditorium, university: universityInContext, context: taskContext)
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
        
        private func insert(_ parsedAuditorium: Auditorium, university: UniversityEntity, context: NSManagedObjectContext) {
            let auditoriumEntity = AuditoriumEntity(context: context)
            auditoriumEntity.id = parsedAuditorium.id
            auditoriumEntity.name = parsedAuditorium.name
            if let firstCharacter = parsedAuditorium.name.first {
                auditoriumEntity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                auditoriumEntity.firstSymbol = ""
            }
            auditoriumEntity.university = university
            auditoriumEntity.slug = parsedAuditorium.slug
        }
    }
}

