//
//  ParseGroupsOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

class ParseGroupsOperation: AsyncOperation {
    
    // MARK: - Properties
    
    let cacheFile: URL
    let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(cacheFile: URL, context: NSManagedObjectContext) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        /*
         Use the overwrite merge policy, because we want any updated objects
         to replace the ones in the store.
         */
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.cacheFile = cacheFile
        self.context = context
        
        super.init()
        
        name = "Parse Groups"
    }
    
    // MARK: - Methods
    
    override func start() {
        super.start()
        
        guard let stream = InputStream(url: cacheFile) else {
            finish()
            return
        }
        stream.open()
        
        defer {
            stream.close()
        }
        do {
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
            if let groups = json?["groups"] as? [[String: Any]] {
                parse(groups)
            } else {
                finish()
            }
        } catch {
            print(error)
        }
    }
    
    private func parse(_ json: [[String: Any]]) {
        let parsedGroups = json.flatMap { GroupStruct($0) }
        context.perform {
            for group in parsedGroups {
                self.insert(group)
            }
            _ = self.saveContext()
            self.finish()
        }
    }
    
    private func insert(_ parsedGroup: GroupStruct) {
        let groupEntitu = GroupEntity(context: context)
        groupEntitu.id = parsedGroup.id
        groupEntitu.name = parsedGroup.name
    }
    
    private func saveContext() -> Error? {
        if context.hasChanges {
            do {
                try context.save()
            } catch  {
                return error
            }
        }
        return nil
    }
}
