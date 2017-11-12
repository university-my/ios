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
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [Any]
            print(json ?? "Empty JSON")
            finish()
        } catch {
            print(error)
        }
    }
}
