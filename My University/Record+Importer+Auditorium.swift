//
//  Record+Importer+Auditorium.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Record.Importer {
    
    class Auditorium {
        
        typealias NetworkClient = Record.NetworkClient
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let context: NSManagedObjectContext
        private let auditorium: AuditoriumEntity
        
        private var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter
        }()
        
        // MARK: - Initialization
        
        init?(context: NSManagedObjectContext, auditorium: AuditoriumEntity) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("auditorium_records.json") else { return nil }
            self.cacheFile = cacheFile
            
            self.context = context
            
            self.auditorium = auditorium
            networkClient = NetworkClient(cacheFile: self.cacheFile)
        }
        
        // MARK: - Methods
        
        func importRecords(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadRecords(auditoriumID: auditorium.id) { (error) in
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
                if let auditorium = json?["auditorium"] as? [String: Any],
                    let records = auditorium["records"] as? [[String: Any]] {
                    
                    // Finish if no records in JSON.
                    if records.isEmpty {
                        completionHandler?(nil)
                        return
                    }
                    
                    // Delete old records first.
                    batchDeleteRecords()
                    
                    // Parse new.
                    parseRecords(records)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        private func batchDeleteRecords() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "auditorium == %@", auditorium)
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
        
        private func parseRecords(_ json: [[String: Any]]) {
            let parsedRecords = json.compactMap { Record($0, dateFormatter: dateFormatter) }
            
            // Finish if no records in JSON.
            if parsedRecords.isEmpty {
                completionHandler?(nil)
                return
            }
            
            context.perform {
                /*
                 Use the overwrite merge policy, because we want any updated objects
                 to replace the ones in the store.
                 */
                self.context.mergePolicy = NSMergePolicy.overwrite
                
                for record in parsedRecords {
                    self.insert(record)
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
        
        private func insert(_ parsedRecord: Record) {
            let recordEntity = RecordEntity(context: context)
            
            recordEntity.id = NSNumber(value: parsedRecord.id).int64Value
            recordEntity.date = parsedRecord.date
            recordEntity.dateString = parsedRecord.dateString
            recordEntity.auditorium = auditorium
            recordEntity.pairName = parsedRecord.pairName
            recordEntity.name = parsedRecord.name
            recordEntity.reason = parsedRecord.reason
            recordEntity.time = parsedRecord.time
            recordEntity.type = parsedRecord.type
        }
        
        
    }
}
