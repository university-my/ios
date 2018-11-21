//
//  AuditoriumsImportManager.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Auditorium {
    
    class ImportManager {
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let client: Auditorium.APIClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let context: NSManagedObjectContext
        
        // MARK: - Initialization
        
        init?(context: NSManagedObjectContext) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("auditoriums.json") else { return nil }
            self.cacheFile = cacheFile
            
            self.context = context
            
            // API client
            client = Auditorium.APIClient(cacheFile: self.cacheFile)
        }
        
        // MARK: - Import Auditoriums
        
        func importAuditoriums(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            client.downloadAuditoriums { (error) in
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
                    
                    // Delete old records first.
                    batchDeleteAuditoriums()
                    
                    parseAuditoriums(auditoriums)
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        private func batchDeleteAuditoriums() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AuditoriumEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDArray = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDArray]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        private func parseAuditoriums(_ json: [[String: Any]]) {
            let parsedAuditoriums = json.compactMap { Auditorium($0) }
            
            context.perform {
                /*
                 Use the overwrite merge policy, because we want any updated objects
                 to replace the ones in the store.
                 */
                self.context.mergePolicy = NSMergePolicy.overwrite
                
                for auditorium in parsedAuditoriums {
                    self.insert(auditorium)
                }
                
                // Finishing import. Save context.
                if self.context.hasChanges {
                    do {
                        try self.context.save()
                        self.completionHandler?(nil)
                    } catch  {
                        self.completionHandler?(error)
                    }
                }
            }
        }
        
        private func insert(_ parsedAuditorium: Auditorium) {
            let auditoriumEntity = AuditoriumEntity(context: context)
            auditoriumEntity.id = parsedAuditorium.id
            auditoriumEntity.name = parsedAuditorium.name
        }
    }
    
}

