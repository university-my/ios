//
//  Record+NetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    class NetworkClient {
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private var completionHandler: ((_ error: Error?) -> ())?
        
        // MARK: - Initialization
        
        init(cacheFile: URL) {
            self.cacheFile = cacheFile
        }
        
        // MARK: - Download Records with Group ID
        
        func downloadRecords(groupID: Int64, _ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            guard let url = URL(string: "http://localhost:3000/universities/sumdu/groups/\(groupID).json") else {
                completionHandler?(nil)
                return
            }
            
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
        // MARK: - Download Records with Auditorium ID
        
        func downloadRecords(auditoriumID: Int64, _ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            guard let url = URL(string: "http://localhost:3000/universities/sumdu/auditoriums/\(auditoriumID).json") else {
                completionHandler?(nil)
                return
            }
            
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
        // MARK: - Helpers
        
        private func downloadFinished(url: URL?, response: URLResponse?) {
            if let localURL = url {
                do {
                    /*
                     If we already have a file at this location, just delete it.
                     Also, swallow the error, because we don't really care about it.
                     */
                    try FileManager.default.removeItem(at: cacheFile)
                }
                catch { }
                
                do {
                    try FileManager.default.moveItem(at: localURL, to: cacheFile)
                    completionHandler?(nil)
                } catch {
                    completionHandler?(error)
                }
            } else {
                completionHandler?(nil)
            }
        }
    }
}
