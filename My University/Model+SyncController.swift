//
//  Model+SyncController.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

extension Model {
    
    class SyncController {
        
        typealias Completion = ((_ result: Result<Bool, Error>) -> ())
        
        // MARK: - Properties
        
        internal var completionHandler: Completion?
        internal var persistentContainer: NSPersistentContainer
        internal weak var university: UniversityEntity?
        internal let importController: ModelImportController<Kind>
        
        // MARK: - Import
        
        func beginSync(_ completion: @escaping Completion) {
            guard let universityURL = university?.url else {
                preconditionFailure()
            }
            completionHandler = completion
            
            importController.importData(universityURL: universityURL) { result in
                
                switch result {
                
                case .failure(let error):
                    self.completionHandler?(.failure(error))
                    
                case .success(let data):
                    // New context for sync
                    let context = self.persistentContainer.newBackgroundContext()
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    context.undoManager = nil
                    
                    self.sync(from: data, in: context)
                }
            }
        }
        
        // MARK: - Initialization
        
        init?(persistentContainer: NSPersistentContainer, universityID: Int64) {
            guard let importController = ModelImportController<Kind>() else { return nil }
            self.importController = importController
            
            self.persistentContainer = persistentContainer
            
            guard let university = UniversityEntity.fetch(id: universityID, context: persistentContainer.viewContext) else { return nil }
            self.university = university
        }
        
        // MARK: - Sync
        
        private func sync(from data: Data, in taskContext: NSManagedObjectContext) {
            
            var objects: [CodingData] = []
            do {
                let decoder = JSONDecoder()
                objects = try decoder.decode([CodingData].self, from: data)
            } catch {
                completionHandler?(.failure(error))
            }
            
            taskContext.performAndWait {
                
                // University in current context
                guard let universityObjectID = university?.objectID else {
                    self.completionHandler?(.success(true))
                    return
                }
                guard let universityInContext = taskContext.object(with: universityObjectID) as? UniversityEntity else {
                    self.completionHandler?(.success(true))
                    return
                }
                
                // Objects to update
                let toUpdate = Model.fetch(objects, for: universityInContext, in: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.compactMap({ object in
                    return object.slug
                })
                
                // Find objects to insert
                let toInsert = objects.filter({ object in
                    return (idsToUpdate.contains(object.slug) == false)
                })
                
                // IDs
                let slugs = objects.map({ classroom in
                    return classroom.slug
                })
                
                // Now find objects to delete
                let allEntities = Model.fetchAll(for: universityInContext, in: taskContext)
                let toDelete = allEntities.filter({ classroom in
                    if let slug = classroom.slug {
                        return (slugs.contains(slug) == false)
                    } else {
                        return true
                    }
                })
                
                // 1. Delete
                for entity in toDelete {
                    taskContext.delete(entity)
                }
                
                // 2. Update
                for entity in toUpdate {
                    if let objectFromServer = objects.first(where: { (parsedObject) -> Bool in
                        return parsedObject.slug == entity.slug
                    }) {
                        // Update name if changed
                        if objectFromServer.name != entity.name {
                            entity.name = objectFromServer.name
                            if let firstCharacter = objectFromServer.name.first {
                                entity.firstSymbol = String(firstCharacter).uppercased()
                            } else {
                                entity.firstSymbol = ""
                            }
                        }
                        
                        if (entity.records?.count ?? 0) > 0 {
                            // Delete all related records
                            // Because NSManagedObject's can be changed to another one.
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                            
                            fetchRequest.predicate = NSPredicate(format: "\(coreDataSingleEntityName) == %@", entity)
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                            deleteRequest.resultType = .resultTypeObjectIDs
                            
                            do {
                                let result = try taskContext.execute(deleteRequest) as? NSBatchDeleteResult
                                if let objectIDArray = result?.result as? [NSManagedObjectID] {
                                    let changes = [NSDeletedObjectsKey: objectIDArray]
                                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
                                }
                            } catch {
                                completionHandler?(.failure(error))
                            }
                        }
                    }
                }
                
                // 3. Insert
                for object in toInsert {
                    self.insert(object, for: universityInContext, in: taskContext)
                }
                
                // Finishing import. Save context.
                if taskContext.hasChanges {
                    do {
                        try taskContext.save()
                    } catch {
                        self.completionHandler?(.failure(error))
                    }
                }
                
                // Reset the context to clean up the cache and low the memory footprint.
                taskContext.reset()
                
                // Finish.
                self.completionHandler?(.success(true))
            }
        }
        
        private func insert(_ object: CodingData, for university: UniversityEntity, in context: NSManagedObjectContext) {
            let entity = CoreDataEntity(context: context)
            entity.id = object.id
            entity.name = object.name
            if let firstCharacter = object.name.first {
                entity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                entity.firstSymbol = ""
            }
            entity.university = university
            entity.slug = object.slug
        }
    }
}
