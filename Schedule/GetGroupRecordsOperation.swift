//
//  GetGroupRecordsOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData

class GetGroupRecordsOperation: GroupOperation {
    
    // MARK: - Properties
    
    let downloadOperation: DownloadGroupRecordsOperation
    let parseOperation: ParseGroupRecordsOperation
    
    // MARK: - Initialization
    
    init?(groupID: Int, context: NSManagedObjectContext, completionHandler: @escaping () -> ()) {
        let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let cacheFile = cachesFolder?.appendingPathComponent("group_records.json") else { return nil }
        downloadOperation = DownloadGroupRecordsOperation(groupID: groupID, cacheFile: cacheFile)
        parseOperation = ParseGroupRecordsOperation(cacheFile: cacheFile, context: context)
        let finishOperation = BlockOperation(block: completionHandler)
        
        // These operations must be executed in order
        parseOperation.addDependency(downloadOperation)
        finishOperation.addDependency(parseOperation)
        
        super.init(operations: [downloadOperation, parseOperation, finishOperation])
        name = "Get Group Records"
    }
}
