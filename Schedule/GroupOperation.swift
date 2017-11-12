//
//  GroupOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 11.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

/**
 A subclass of `AsyncOperation` that executes zero or more operations as part of its
 own execution. This class of operation is very useful for abstracting several
 smaller operations into a larger operation.
 */
class GroupOperation: AsyncOperation {
    
    // MARK: - Properties
    
    private let internalQueue = OperationQueue()
    private let startingOperation = BlockOperation(block: {})
    private let finishingOperation = BlockOperation(block: {})
    
    private var aggregatedErrors = [Error]()
    
    convenience init(operations: Operation...) {
        self.init(operations: operations)
    }
    
    // MARK: - Initialization
    
    init(operations: [Operation]) {
        super.init()
        internalQueue.isSuspended = true
        internalQueue.addOperation(startingOperation)
        
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    // MARK: - Methods
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func start() {
        super.start()
        
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    func add(_ operation: Operation) {
        internalQueue.addOperation(operation)
    }
}
