//
//  GetGroupsOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData

class GetGroupsOperation: GroupOperation {
    
    // MARK: - Properties
    
    let downloadOperation: DownloadGroupsOperation
    let parseOperation: ParseGroupsOperation
    
    // MARK: - Initialization
    
    init?(context: NSManagedObjectContext, completionHandler: @escaping () -> ()) {
        let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let cacheFile = cachesFolder?.appendingPathComponent("groups.json") else { return nil }
        downloadOperation = DownloadGroupsOperation(cacheFile: cacheFile)
        parseOperation = ParseGroupsOperation(cacheFile: cacheFile, context: context)
        let finishOperation = BlockOperation(block: completionHandler)
        
        // These operations must be executed in order
        parseOperation.addDependency(downloadOperation)
        finishOperation.addDependency(parseOperation)
        
        super.init(operations: [downloadOperation, parseOperation, finishOperation])
        name = "Get Groups"
    }
}
