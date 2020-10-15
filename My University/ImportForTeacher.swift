//
//  ImportForTeacher.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData

extension Record {
    
    final class ImportForTeacher: BaseRecordImportController<ModelKinds.TeacherModel> {
        
        /// Delete previous records and insert new records
        override func sync(_ records: [Record.CodingData], taskContext: NSManagedObjectContext) {
            
            taskContext.performAndWait {
                
                guard let teacherInContext = TeacherEntity.fetch(id: modelID, context: taskContext) else {
                    self.completionHandler?(nil)
                    return
                }
                
                // Records to update
                let toUpdate = RecordEntity.fetch(records, teacher: teacherInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ record in
                    return record.id
                })
                
                // Find records to insert
                let toInsert = records.filter({ record in
                    return (idsToUpdate.contains(record.id) == false)
                })
                
                // Update
                for record in toUpdate {
                    if let recordFromServer = records.first(where: { parsedRecord in
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
                    self.insert(record, teacher: teacherInContext, context: taskContext)
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
        
        private func insert(_ parsedRecord: Record.CodingData, teacher: TeacherEntity, context: NSManagedObjectContext) {
            let recordEntity = RecordEntity(context: context)
            
            recordEntity.id = NSNumber(value: parsedRecord.id).int64Value
            recordEntity.date = parsedRecord.date
            recordEntity.dateString = parsedRecord.dateString
            recordEntity.pairName = parsedRecord.pairName
            recordEntity.name = parsedRecord.name
            recordEntity.reason = parsedRecord.reason
            recordEntity.time = parsedRecord.time
            recordEntity.type = parsedRecord.type
            
            // Fetch classroom entity for set relation with record
            if let object = parsedRecord.classroom {
                recordEntity.classroom = ClassroomEntity.fetch(id: object.id, context: context)
            }
            
            // Groups
            let groups = GroupEntity.fetch(parsedRecord.groups, university: teacher.university, context: context)
            let set = NSSet(array: groups)
            recordEntity.addToGroups(set)
            
            // Teacher
            recordEntity.teacher = teacher
        }
    }
}
