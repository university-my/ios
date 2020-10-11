//
//  Teacher+ImportController.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData

extension Teacher {
    
    final class ImportController: BaseImportController<ModelKinds.TeacherModel> {
        
        func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
            guard let universityURL = university?.url else {
                preconditionFailure()
            }
            completionHandler = completion
            
            importController.importData(universityURL: universityURL) { (json, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    // New context for sync
                    let context = self.persistentContainer.newBackgroundContext()
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    context.undoManager = nil
                    
                    self.syncTeachers(from: json, taskContext: context)
                }
            }
        }
        
        /// Delete previous groups and insert new
        private func syncTeachers(from json: [[String: Any]], taskContext: NSManagedObjectContext) {
            
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
                
                // Parse teachers.
                let parsedTeachers = json.compactMap { Teacher.CodingData($0) }
                
                // Teachers to update
                let toUpdate = TeacherEntity.fetch(parsedTeachers, university: universityInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.compactMap({ teacher in
                    return teacher.slug
                })
                
                // Find teachers to insert
                let toInsert = parsedTeachers.filter({ teachers in
                    return (idsToUpdate.contains(teachers.slug) == false)
                })
                
                // IDs
                let slugs = parsedTeachers.map({ teachers in
                    return teachers.slug
                })
                
                // Now find teachers to delete
                let allTeachers = TeacherEntity.fetchAll(university: universityInContext, context: taskContext)
                let toDelete = allTeachers.filter({ teacher in
                  if let slug = teacher.slug {
                    return (slugs.contains(slug) == false)
                  } else {
                    return true
                  }
                })
                
                // 1. Delete
                for group in toDelete {
                    taskContext.delete(group)
                }
                
                // 2. Update
                for teacher in toUpdate {
                    if let teacherFromServer = parsedTeachers.first(where: { (parsedTeacher) -> Bool in
                        return parsedTeacher.slug == teacher.slug
                    }) {
                        // Update name if changed
                        if teacherFromServer.name != teacher.name {
                            teacher.name = teacherFromServer.name
                            if let firstCharacter = teacherFromServer.name.first {
                                teacher.firstSymbol = String(firstCharacter).uppercased()
                            } else {
                                teacher.firstSymbol = ""
                            }
                        }
                        
                        if (teacher.records?.count ?? 0) > 0 {
                            // Delete all related records
                            // Because Teacher can be changed to another one.
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordEntity.fetchRequest()
                            
                            fetchRequest.predicate = NSPredicate(format: "teacher == %@", teacher)
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
                for teacher in toInsert {
                    self.insert(teacher, university: universityInContext, context: taskContext)
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
        
        private func insert(_ parsedTeacher: Teacher.CodingData, university: UniversityEntity, context: NSManagedObjectContext) {
            let teacherEntity = TeacherEntity(context: context)
            teacherEntity.id = parsedTeacher.id
            teacherEntity.name = parsedTeacher.name
            if let firstCharacter = parsedTeacher.name.first {
                teacherEntity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                teacherEntity.firstSymbol = ""
            }
            teacherEntity.university = university
            teacherEntity.slug = parsedTeacher.slug
        }
    }
}
