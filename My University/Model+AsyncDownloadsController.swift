//
//  Model+AsyncDownloadsController.swift
//  My University
//
//  Created by Yura Voevodin on 10.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

extension Model {
    
    class AsyncDownloadsController {
        private let cacheFile: URL
        
        internal init(cacheFile: URL) {
            self.cacheFile = cacheFile
        }
        
        func download(universityURL: String) async throws {
            // URL to the model API
            let url = Kind.allEntities(university: universityURL)
            
            let result = try await URLSession.shared.download(from: url)
            
            /*
             If we already have a file at this location, just delete it.
             Also, swallow the error, because we don't really care about it.
             */
            try? FileManager.default.removeItem(at: cacheFile)
            
            let fileURL = result.0
            try FileManager.default.moveItem(at: fileURL, to: cacheFile)
        }
    }
}
