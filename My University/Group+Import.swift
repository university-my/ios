//
//  Group+Import.swift
//  My University
//
//  Created by Yura Voevodin on 12/19/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Group {
    
    class Import {
        
        typealias NetworkClient = Group.NetworkClient
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let persistentContainer: NSPersistentContainer
        private let university: UniversityEntity
        
        // MARK: - Initialization
        
        init?(persistentContainer: NSPersistentContainer, university: UniversityEntity) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("groups.json") else { return nil }
            
            self.cacheFile = cacheFile
            self.persistentContainer = persistentContainer
            networkClient = NetworkClient(cacheFile: self.cacheFile)
            self.university = university
        }
        
        // MARK: - Methods
        
        func importGroups(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadGroups(universityURL: university.url) { (error) in
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
                    
                    syncGroups(from: json, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        /// Delete previous groups and insert new
        private func syncGroups(from json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                // University in current context
                guard let universityInContext = taskContext.object(with: university.objectID) as? UniversityEntity else {
                    return
                }
                
                // Parse groups.
                let parsedGroups = json.compactMap { Group($0) }
                
                // Groups to update
                let toUpdate = GroupEntity.fetch(parsedGroups, university: universityInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ group in
                    return group.id
                })
                
                // Find groups to insert
                let toInsert = parsedGroups.filter({ group in
                    return (idsToUpdate.contains(group.id) == false)
                })
                
                // IDs
                let ids = parsedGroups.map({ group in
                    return group.id
                })
                
                // Now find groups to delete
                let allGroups = GroupEntity.fetchAll(university: universityInContext, context: taskContext)
                let toDelete = allGroups.filter({ university in
                    return (ids.contains(university.id) == false)
                })
                
                // 1. Delete
                for group in toDelete {
                    taskContext.delete(group)
                }
                
                // 2. Update
                for group in toUpdate {
                    if let groupFromServer = parsedGroups.first(where: { (parsedGroup) -> Bool in
                        return parsedGroup.id == group.id
                    }) {
                        // Update name if changed
                        if groupFromServer.name != group.name {
                            group.name = groupFromServer.name
                            if let firstCharacter = groupFromServer.name.first {
                                group.firstSymbol = String(firstCharacter).uppercased()
                            } else {
                                group.firstSymbol = ""
                            }
                        }
                        
                        if (group.records?.count ?? 0) > 0 {
                            // Delete all related records
                            // Because Group can be changed to another one.
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                            
                            fetchRequest.predicate = NSPredicate(format: "ANY groups = %@", group)
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
                for group in toInsert {
                    self.insert(group, context: taskContext)
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
                self.persistentContainer.viewContext.refreshAllObjects()
                
                // Finish.
                self.completionHandler?(nil)
            }
        }
        
        private func insert(_ parsedGroup: Group, context: NSManagedObjectContext) {
            let groupEntity = GroupEntity(context: context)
            
            if let firstCharacter = parsedGroup.name.first {
                groupEntity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                groupEntity.firstSymbol = ""
            }
            groupEntity.id = parsedGroup.id
            groupEntity.name = parsedGroup.name
            
            if let universityInContext = context.object(with: university.objectID) as? UniversityEntity {
                groupEntity.university = universityInContext
            }
        }
    }
}
