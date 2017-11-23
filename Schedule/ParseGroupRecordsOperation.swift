//
//  ParseGroupRecordsOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

class ParseGroupRecordsOperation: AsyncOperation {
    
    // MARK: - Properties
    
    let cacheFile: URL
    let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(cacheFile: URL, context: NSManagedObjectContext) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        self.cacheFile = cacheFile
        self.context = context
        
        super.init()
        
        name = "Parse Group Records"
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
            if let group = json?["group"] as? [String: Any],
                let records = group["records"] as? [[String: Any]] {
                parse(records)
            } else {
                finish()
            }
        } catch {
            print(error)
            finish()
        }
    }
    
    private func parse(_ json: [[String: Any]]) {
        let parsedRecords = json.flatMap { RecordStruct($0) }
        
        context.perform {
            /*
             Use the overwrite merge policy, because we want any updated objects
             to replace the ones in the store.
             */
            self.context.mergePolicy = NSMergePolicy.overwrite
            
            for group in parsedRecords {
                self.insert(group)
            }
            let saveError = self.saveContext()
            if let error = saveError {
                print(error)
            }
            self.finish()
        }
    }
    
    private func insert(_ parsedRecord: RecordStruct) {
        let recordEntity = RecordEntity(context: context)
        
        recordEntity.dateString = parsedRecord.dateString
        recordEntity.pairName = parsedRecord.pairName
        recordEntity.reason = parsedRecord.reason
        recordEntity.time = parsedRecord.time
        recordEntity.type = parsedRecord.type
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
