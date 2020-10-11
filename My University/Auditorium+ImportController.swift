//
//  Auditorium+ImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Auditorium {
    
    final class ImportController: BaseModelImportController<ModelKinds.ClassroomModel> {
        
        /// Delete previous groups and insert new
        override func sync(from json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
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
                
                // Parse auditoriums
                let parsedAuditoriums = json.compactMap { Auditorium.CodingData($0) }
                
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
        
        private func insert(_ parsedAuditorium: Auditorium.CodingData, university: UniversityEntity, context: NSManagedObjectContext) {
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
