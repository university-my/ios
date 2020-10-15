//
//  Classroom+ImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData

extension Classroom {
    
    final class ImportController: BaseModelImportController<ModelKinds.ClassroomModel> {
        
        /// Delete previous groups and insert new
        override func sync(from data: Data, taskContext: NSManagedObjectContext) {
            
            var classrooms: [Classroom.CodingData] = []
            do {
                let decoder = JSONDecoder()
                classrooms = try decoder.decode([Classroom.CodingData].self, from: data)
            } catch {
                completionHandler?(error)
            }
            
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
                
                // Classrooms to update
                let toUpdate = ClassroomEntity.fetch(classrooms, university: universityInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.compactMap({ classroom in
                    return classroom.slug
                })
                
                // Find classrooms to insert
                let toInsert = classrooms.filter({ classroom in
                    return (idsToUpdate.contains(classroom.slug) == false)
                })
                
                // IDs
                let slugs = classrooms.map({ classroom in
                    return classroom.slug
                })
                
                // Now find classrooms to delete
                let allClassrooms = ClassroomEntity.fetchAll(university: universityInContext, context: taskContext)
                let toDelete = allClassrooms.filter({ classroom in
                    if let slug = classroom.slug {
                        return (slugs.contains(slug) == false)
                    } else {
                        return true
                    }
                })
                
                // 1. Delete
                for classroom in toDelete {
                    taskContext.delete(classroom)
                }
                
                // 2. Update
                for classroom in toUpdate {
                    if let classroomFromServer = classrooms.first(where: { (parsedClassroom) -> Bool in
                        return parsedClassroom.slug == classroom.slug
                    }) {
                        // Update name if changed
                        if classroomFromServer.name != classroom.name {
                            classroom.name = classroomFromServer.name
                            if let firstCharacter = classroomFromServer.name.first {
                                classroom.firstSymbol = String(firstCharacter).uppercased()
                            } else {
                                classroom.firstSymbol = ""
                            }
                        }
                        
                        if (classroom.records?.count ?? 0) > 0 {
                            // Delete all related records
                            // Because Classroom can be changed to another one.
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                            
                            fetchRequest.predicate = NSPredicate(format: "classroom == %@", classroom)
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
                for classroom in toInsert {
                    self.insert(classroom, university: universityInContext, context: taskContext)
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
        
        private func insert(_ classroom: Classroom.CodingData, university: UniversityEntity, context: NSManagedObjectContext) {
            let entity = ClassroomEntity(context: context)
            entity.id = classroom.id
            entity.name = classroom.name
            if let firstCharacter = classroom.name.first {
                entity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                entity.firstSymbol = ""
            }
            entity.university = university
            entity.slug = classroom.slug
        }
    }
}
