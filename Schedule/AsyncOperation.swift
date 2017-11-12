//
//  AsyncOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 11.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    // MARK: - Properties
    
    /// A lock to guard reads and writes to the `internalState` property
    private let stateLock = NSLock()
    
    /// Internal state of the operation
    private var internalState: State = .ready
    
    /// Public state
    var state: State {
        get {
            return stateLock.withCriticalScope {
                internalState
            }
        }
        set(newState) {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newState.keyPath)
            stateLock.withCriticalScope {
                internalState = newState
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: newState.keyPath)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - Methods
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
    }
    
    override func cancel() {
        state = .finished
    }
    
    final func finish() {
        state = .finished
    }
}

// MARK: - State

extension AsyncOperation {
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
}
