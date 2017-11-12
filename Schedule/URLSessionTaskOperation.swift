//
//  URLSessionTaskOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 11.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

class URLSessionTaskOperation: Operation {
    
    // MARK: - Properties
    
    let task: URLSessionTask
    
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
            willChangeValue(forKey: newState.keyPath)
            willChangeValue(forKey: state.keyPath)
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
    
    // MARK: - Initialization
    
    init(task: URLSessionTask) {
        self.task = task
        super.init()
    }
    
    override func start() {
        state = .executing
        
        task.addObserver(self, forKeyPath: "state", options: [], context: nil)
        task.resume()
    }
    
    override func cancel() {
        task.removeObserver(self, forKeyPath: "state")
        state = .finished
        task.cancel()
        super.cancel()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let taskObject = object as? URLSessionTask, taskObject == task, task.state == .completed {
            task.removeObserver(self, forKeyPath: "state")
            state = .finished
        }
    }
}

// MARK: - State

extension URLSessionTaskOperation {
    
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
}
