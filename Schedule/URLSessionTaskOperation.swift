//
//  URLSessionTaskOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 11.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class URLSessionTaskOperation: AsyncOperation {
    
    // MARK: - Properties
    
    let task: URLSessionTask
    
    // MARK: - Initialization
    
    init(task: URLSessionTask) {
        self.task = task
        super.init()
    }
    
    override func start() {
        super.start()
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        task.addObserver(self, forKeyPath: "state", options: [], context: nil)
        task.resume()
    }
    
    override func cancel() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        task.removeObserver(self, forKeyPath: "state")
        task.cancel()
        super.cancel()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let taskObject = object as? URLSessionTask, taskObject == task {
            
            switch task.state {
            case .completed, .canceling:
                task.removeObserver(self, forKeyPath: "state")
                finish()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            default:
                break
            }
        }
    }
}
