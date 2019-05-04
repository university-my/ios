//
//  ImportForGroup.swift
//  My University
//
//  Created by Yura Voevodin on 12/9/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Record {
    
    class ImportForGroup {
        
        typealias NetworkClient = Record.NetworkClient
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private let group: GroupEntity
        private let university: UniversityEntity
        
        private let persistentContainer: NSPersistentContainer
        
        private var viewContext: NSManagedObjectContext {
            return persistentContainer.viewContext
        }
        
        private var dateFormatter: ISO8601DateFormatter = {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return dateFormatter
        }()
        
        // MARK: - Initialization
        
        init?(persistentContainer: NSPersistentContainer, group: GroupEntity, university: UniversityEntity) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("group_records.json") else { return nil }
            
            self.cacheFile = cacheFile
            self.persistentContainer = persistentContainer
            self.group = group
            self.university = university
            networkClient = NetworkClient(cacheFile: self.cacheFile)
        }
        
        // MARK: - Methods
        
        /// Download and save to file
        func importRecords(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadRecords(groupID: group.id, unversityURL: university.url ?? "") { (error) in
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.serializeJSON()
                }
            }
        }
        
        /// Read from file
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
                let object = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
                let records = object?.first { key, _ in
                    return key == "records"
                }
                if let records = records?.value as? [[String: Any]] {
                    
                    // Finish if no records in JSON.
                    if records.isEmpty {
                        completionHandler?(nil)
                        return
                    }

                    // New context for sync.
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    syncRecords(records, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
            }
        }
        
        /// Delete previous records and insert new records
        private func syncRecords(_ json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            guard let groupInContext = taskContext.object(with: group.objectID) as? GroupEntity else { return }
            
            taskContext.performAndWait {
                
                // TODO: Don't delete records
                
                // Execute the request to batch delete and merge the changes to viewContext.
                
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(format: "ANY groups = %@", groupInContext)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                do {
                    let result = try taskContext.execute(deleteRequest) as? NSBatchDeleteResult
                    if let objectIDArray = result?.result as? [NSManagedObjectID] {
                        let changes = [NSDeletedObjectsKey: objectIDArray]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                    }
                } catch {
                    completionHandler?(error)
                }
                
                // Create new records.
                
                let parsedRecords = json.compactMap { Record($0, dateFormatter: dateFormatter) }
                
                // Finish if no records in JSON.
                if parsedRecords.isEmpty {
                    completionHandler?(nil)
                    return
                }
                
                for record in parsedRecords {
                    self.insert(record, group: groupInContext, context: taskContext)
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
                self.viewContext.refreshAllObjects()
                
                // Finish.
                self.completionHandler?(nil)
            }
        }
        
        /// Insert new record with related group
        private func insert(_ parsedRecord: Record, group: GroupEntity, context: NSManagedObjectContext) {
            let recordEntity = RecordEntity(context: context)
            
            recordEntity.id = NSNumber(value: parsedRecord.id).int64Value
            recordEntity.date = parsedRecord.date
            recordEntity.dateString = parsedRecord.dateString
            recordEntity.pairName = parsedRecord.pairName
            recordEntity.name = parsedRecord.name
            recordEntity.reason = parsedRecord.reason
            recordEntity.time = parsedRecord.time
            recordEntity.type = parsedRecord.type
            
            // Fetch auditorium entity for set relation with record
            if let object = parsedRecord.auditorium {
                recordEntity.auditorium = AuditoriumEntity.fetch(id: object.id, context: context)
            }
            
            // Groups
            let groups = GroupEntity.fetch(parsedRecord.groups, university: group.university, context: context)
            let set = NSSet(array: groups)
            recordEntity.addToGroups(set)
            
            // Fetch teacher entity for set relation with record
            if let object = parsedRecord.teacher {
                recordEntity.teacher = TeacherEntity.fetchTeacher(id: object.id, context: context)
            }
        }
    }
}
