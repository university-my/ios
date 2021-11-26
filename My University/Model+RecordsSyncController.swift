//
//  Model+RecordsSyncController.swift
//  My University
//
//  Created by Yura Voevodin on 16.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

extension Model {
    
    class RecordsSyncController {
        
        typealias Completion = ((_ result: Result<Bool, Error>) -> ())
        
        // MARK: - Properties
        
        internal let modelID: Int64
        internal let networkClient: NetworkClient<Record.RecordsList>
        internal let persistentContainer: NSPersistentContainer
        internal let university: UniversityEntity
        internal var completionHandler: Completion?
        
        // MARK: - Initialization
        
        init(persistentContainer: NSPersistentContainer, modelID: Int64, university: UniversityEntity) {
            self.modelID = modelID
            self.persistentContainer = persistentContainer
            self.university = university
            networkClient = NetworkClient()
        }
        
        // MARK: - Import
        
        func importRecords(for date: Date, decoder: JSONDecoder, _ completion: @escaping Completion) {
            completionHandler = completion
            
            let dateString = DateFormatter.short.string(from: date)
            let params = Record.RequestParameters(id: modelID, university: university.url ?? "", date: dateString)
            let url = Kind.recordsEndpoint(params: params)
            
            networkClient.load(url, decoder: decoder) { (result) in
                switch result {
                
                case .failure(let error):
                    self.completionHandler?(.failure(error))
                    
                case .success(let list):
                    // New context for sync
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    self.sync(list.records, in: taskContext)
                }
            }
        }
        
        // MARK: - Sync
        
        func sync(_ records: [Record.CodingData], in context: NSManagedObjectContext) {
            
            context.performAndWait {
                
                guard let entityInContext = Model.fetch(id: modelID, context: context) else {
                    self.completionHandler?(.success(false))
                    return
                }
                
                // Records to update
                let toUpdate = fetch(records, for: entityInContext, in: context)
                
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
                    self.insert(record, in: context)
                }
                
                // Finishing import. Save context.
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        self.completionHandler?(.failure(error))
                    }
                }
                
                // Reset the context to clean up the cache and low the memory footprint.
                context.reset()
                
                // Finish
                self.completionHandler?(.success(true))
            }
        }
        
        private func fetch(_ records: [Record.CodingData], for entity: CoreDataEntity, in context: NSManagedObjectContext) -> [RecordEntity] {
            if let classroom = entity as? ClassroomEntity {
                return RecordEntity.fetch(records, classroom: classroom, context: context)
                
            } else if let group = entity as? GroupEntity {
                return RecordEntity.fetch(records, group: group, context: context)
                
            } else if let teacher = entity as? TeacherEntity {
                return RecordEntity.fetch(records, teacher: teacher, context: context)
            } else {
                preconditionFailure()
            }
        }
        
        private func insert(_ record: Record.CodingData, in context: NSManagedObjectContext) {
            let newRecord = RecordEntity(context: context)
            
            newRecord.id = NSNumber(value: record.id).int64Value
            newRecord.date = record.date
            newRecord.dateString = record.dateString
            newRecord.pairName = record.pairName
            newRecord.name = record.name
            newRecord.reason = record.reason
            newRecord.time = record.time
            newRecord.type = record.type
            
            // Fetch classroom entity for set relation with record
            if let object = record.classroom {
                newRecord.classroom = Classroom.fetch(id: object.id, context: context)
            }
            
            // Groups
            let groups = Group.fetch(record.groups, for: university, in: context)
            let set = NSSet(array: groups)
            newRecord.addToGroups(set)
            
            // Fetch teacher entity for set relation with record
            if let object = record.teacher {
                newRecord.teacher = Teacher.fetch(id: object.id, context: context)
            }
        }
    }
}
