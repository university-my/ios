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
        private let persistentContainer: NSPersistentContainer
        
        // MARK: - Initialization
        
        init?(persistentContainer: NSPersistentContainer) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("auditoriums.json") else { return nil }
            
            self.cacheFile = cacheFile
            self.persistentContainer = persistentContainer
            networkClient = NetworkClient(cacheFile: self.cacheFile)
        }
        
        // MARK: - Methods
        
        func importAuditoriums(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadAuditoriums { (error) in
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
                let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
                if let auditoriums = json?["auditoriums"] as? [[String: Any]] {
                    
                    // New context for sync.
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    syncAuditoriums(auditoriums, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        /// Delete previous groups and insert new
        private func syncAuditoriums(_ json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                // Execute the request to batch delete and merge the changes to viewContext.
                
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AuditoriumEntity.fetchRequest()
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
                
                // Create new records.
                
                let parsedAuditoriums = json.compactMap { Auditorium($0) }
                
                for auditorium in parsedAuditoriums {
                    self.insert(auditorium, context: taskContext)
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
        
        private func insert(_ parsedAuditorium: Auditorium, context: NSManagedObjectContext) {
            let auditoriumEntity = AuditoriumEntity(context: context)
            auditoriumEntity.id = parsedAuditorium.id
            auditoriumEntity.name = parsedAuditorium.name
            if let firstCharacter = parsedAuditorium.name.first {
                auditoriumEntity.firstSymbol = String(firstCharacter)
            } else {
                auditoriumEntity.firstSymbol = ""
            }
        }
    }
}

