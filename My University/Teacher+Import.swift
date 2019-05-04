//
//  Teacher+Import.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData

extension Teacher {
    
    class Import {
        
        typealias NetworkClient = Teacher.NetworkClient
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private let networkClient: NetworkClient
        private var completionHandler: ((_ error: Error?) -> ())?
        private var persistentContainer: NSPersistentContainer
        private weak var university: UniversityEntity?
        
        // MARK: - Init
        
        init?(persistentContainer: NSPersistentContainer, universityID: Int64) {
            // Cache file
            let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            guard let cacheFile = cachesFolder?.appendingPathComponent("teachers.json") else { return nil }
            
            self.cacheFile = cacheFile
            networkClient = NetworkClient(cacheFile: self.cacheFile)
            
            self.persistentContainer = persistentContainer
            
            guard let university = UniversityEntity.fetch(id: universityID, context: persistentContainer.viewContext) else { return nil }
            self.university = university
        }
        
        // MARK: - Methods
        
        func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            networkClient.downloadTeachers(universityURL: university?.url ?? "") { (error) in
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
                let object = try JSONSerialization.jsonObject(with: stream, options: []) as? [Any]
                if let json = object as? [[String: Any]] {
                    // New context for sync.
                    let taskContext = self.persistentContainer.newBackgroundContext()
                    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    taskContext.undoManager = nil
                    
                    syncTeachers(from: json, taskContext: taskContext)
                    
                } else {
                    completionHandler?(nil)
                }
            } catch {
                completionHandler?(error)
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
                let parsedTeachers = json.compactMap { Teacher($0) }
                
                // Teachers to update
                let toUpdate = TeacherEntity.fetch(parsedTeachers, university: universityInContext, context: taskContext)
                
                // IDs to update
                let idsToUpdate = toUpdate.map({ teacher in
                    return teacher.id
                })
                
                // Find teachers to insert
                let toInsert = parsedTeachers.filter({ teachers in
                    return (idsToUpdate.contains(teachers.id) == false)
                })
                
                // IDs
                let ids = parsedTeachers.map({ teachers in
                    return teachers.id
                })
                
                // Now find teachers to delete
                let allTeachers = TeacherEntity.fetchAll(university: universityInContext, context: taskContext)
                let toDelete = allTeachers.filter({ university in
                    return (ids.contains(university.id) == false)
                })
                
                // 1. Delete
                for group in toDelete {
                    taskContext.delete(group)
                }
                
                // 2. Update
                for teacher in toUpdate {
                    if let teacherFromServer = parsedTeachers.first(where: { (parsedTeacher) -> Bool in
                        return parsedTeacher.id == teacher.id
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
                self.persistentContainer.viewContext.refreshAllObjects()
                
                // Finish.
                self.completionHandler?(nil)
            }
        }
        
        private func insert(_ parsedTeacher: Teacher, university: UniversityEntity, context: NSManagedObjectContext) {
            let teacherEntity = TeacherEntity(context: context)
            teacherEntity.id = parsedTeacher.id
            teacherEntity.name = parsedTeacher.name
            if let firstCharacter = parsedTeacher.name.first {
                teacherEntity.firstSymbol = String(firstCharacter).uppercased()
            } else {
                teacherEntity.firstSymbol = ""
            }
            teacherEntity.university = university
        }
    }
}
