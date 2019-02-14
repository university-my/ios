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
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Init
    
    init?(persistentContainer: NSPersistentContainer) {
      // Cache file
      let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      guard let cacheFile = cachesFolder?.appendingPathComponent("teachers.json") else { return nil }
      
      self.cacheFile = cacheFile
      self.persistentContainer = persistentContainer
      networkClient = NetworkClient(cacheFile: self.cacheFile)
    }
    
    // MARK: - Methods
    
    func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
      completionHandler = completion
      
      networkClient.downloadTeachers { (error) in
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
        
        // Execute the request to batch delete and merge the changes to viewContext.
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TeacherEntity.fetchRequest()
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
        
        // Create new records.
        
        let parsedTeachers = json.compactMap { Teacher($0) }
        
        for teacher in parsedTeachers {
          self.insert(teacher, context: taskContext)
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
    
    private func insert(_ parsedTeacher: Teacher, context: NSManagedObjectContext) {
      let teacherEntity = TeacherEntity(context: context)
      teacherEntity.id = parsedTeacher.id
      teacherEntity.name = parsedTeacher.name
      if let firstCharacter = parsedTeacher.name.first {
        teacherEntity.firstSymbol = String(firstCharacter).uppercased()
      } else {
        teacherEntity.firstSymbol = ""
      }
    }
  }
}
