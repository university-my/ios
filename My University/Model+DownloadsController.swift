//
//  Model+DownloadsController.swift
//  My University
//
//  Created by Yura Voevodin on 16.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import os.log

extension Model {
    
    class DownloadsController {
        
        // MARK: - Properties
        
        let cacheFile: URL
        var completionHandler: ((_ error: Error?) -> ())?
        private let logger = Logger(subsystem: Bundle.identifier, category: "Model.NetworkController")
        
        // MARK: - Initialization
        
        init(cacheFile: URL) {
            self.cacheFile = cacheFile
        }
        
        // MARK: - Download
        
        func download(universityURL: String?, _ completion: @escaping ((_ error: Error?) -> ())) {
            guard let universityURL = universityURL else { return }
            completionHandler = completion
            
            // URL to the model API
            let url = Kind.allEntities(university: universityURL)
            
            logger.info("\(url.absoluteString)")
            
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
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
