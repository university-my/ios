//
//  DownloadGroupRecordsOperation.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class DownloadGroupRecordsOperation: GroupOperation {
    
    // MARK: - Properties
    
    let cacheFile: URL
    let group: GroupEntity
    
    // MARK: - Initialization
    
    init(group: GroupEntity, cacheFile: URL) {
        self.group = group
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Group Records"
    }
    
    // MARK: - Methods
    
    override func start() {
        super.start()
        
        guard let url = URL(string: "https://sumdubot.voevodin-yura.com/groups/\(group.id)") else {
            finish()
            return
        }
        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            self.downloadFinished(url: url, response: response, error: error)
        }
        let taskOperation = URLSessionTaskOperation(task: task)
        add(taskOperation)
    }
    
    private func downloadFinished(url: URL?, response: URLResponse?, error: Error?) {
        defer {
            finish()
        }
        do {
            /*
             If we already have a file at this location, just delete it.
             Also, swallow the error, because we don't really care about it.
             */
            try FileManager.default.removeItem(at: cacheFile)
        }
        catch { }
        
        if let localURL = url {
            do {
                try FileManager.default.moveItem(at: localURL, to: cacheFile)
            } catch {
                print(error)
            }
        } else if let error = error {
            print(error)
        }
    }
}
