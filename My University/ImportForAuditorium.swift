//
//  ImportForAuditorium.swift
//  My University
//
//  Created by Yura Voevodin on 12/9/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Record {
    
    final class ImportForAuditorium: BaseRecordImportController<ModelKinds.ClassroomModel> {
        
        /// Delete previous records and insert new records
        override func syncRecords(_ json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                guard let auditoriumInContext = AuditoriumEntity.fetch(id: modelID, context: taskContext) else {
                    self.completionHandler?(nil)
                    return
                }
                
                // Parse records
                let parsedRecords = json.compactMap { Record.CodingData($0, dateFormatter: dateFormatter) }
                
                // Records to update
                let toUpdate = RecordEntity.fetch(parsedRecords, auditorium: auditoriumInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ record in
                    return record.id
                })
                
                // Find records to insert
                let toInsert = parsedRecords.filter({ record in
                    return (idsToUpdate.contains(record.id) == false)
                })
                
                // Update
                for record in toUpdate {
                    if let recordFromServer = parsedRecords.first(where: { parsedRecord in
                        return parsedRecord.id == record.id
                    }) {
                        record.date = recordFromServer.date
                        record.dateString = recordFromServer.dateString
                        record.pairName = recordFromServer.pairName
                        record.name = recordFromServer.name
                        record.reason = recordFromServer.reason
                        record.time = recordFromServer.time
                        record.type = recordFromServer.type
                    }
                }
                
                // Insert
                for record in toInsert {
                    self.insert(record, auditorium: auditoriumInContext, context: taskContext)
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
        
        private func insert(_ parsedRecord: Record.CodingData, auditorium: AuditoriumEntity, context: NSManagedObjectContext) {
            let recordEntity = RecordEntity(context: context)
            
            recordEntity.id = NSNumber(value: parsedRecord.id).int64Value
            recordEntity.date = parsedRecord.date
            recordEntity.dateString = parsedRecord.dateString
            recordEntity.pairName = parsedRecord.pairName
            recordEntity.name = parsedRecord.name
            recordEntity.reason = parsedRecord.reason
            recordEntity.time = parsedRecord.time
            recordEntity.type = parsedRecord.type
            
            // Auditorium
            recordEntity.auditorium = auditorium
            
            // Groups
            let groups = GroupEntity.fetch(parsedRecord.groups, university: auditorium.university, context: context)
            let set = NSSet(array: groups)
            recordEntity.addToGroups(set)
            
            // Fetch teacher entity for set relation with record
            if let object = parsedRecord.teacher {
                recordEntity.teacher = TeacherEntity.fetch(id: object.id, context: context)
            }
        }
    }
}
