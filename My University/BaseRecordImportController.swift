//
//  BaseRecordImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

class BaseRecordImportController<Model: ModelKind> {
    
    typealias NetworkClient = Record.NetworkClient<Model>
 
    // MARK: - Properties
    
    internal let cacheFile: URL
    internal let networkClient: NetworkClient
    internal var completionHandler: ((_ error: Error?) -> ())?
    internal let modelID: Int64
    internal let universityURL: String
    
    internal let persistentContainer: NSPersistentContainer
    
    internal var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    internal var dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter
    }()
    
    // MARK: - Initialization
    
    init?(persistentContainer: NSPersistentContainer, modelID: Int64, universityURL: String) {
        // Cache file
        let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let cacheFile = cachesFolder?.appendingPathComponent("\(Model.cashFileName)_records.json") else { return nil }
        
        self.cacheFile = cacheFile
        self.modelID = modelID
        self.universityURL = universityURL
        self.persistentContainer = persistentContainer
        networkClient = NetworkClient(cacheFile: self.cacheFile)
    }
    
    // MARK: - Methods
    
    internal func serializeJSON(_ completion: ((_ records: [[String : Any]], _ error: Error?) -> Void)) {
        guard let stream = InputStream(url: cacheFile) else {
            completion([], nil)
            return
        }
        stream.open()
        
        defer {
            stream.close()
        }
        do {
            let object = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
            let records = object?.first { key, _ in
                return key == "records"
            }
            if let records = records?.value as? [[String: Any]] {
                
                // Finish if no records in JSON
                if records.isEmpty {
                    completion([], nil)
                    return
                }
                
                completion(records, nil)
                
            } else {
                completion([], nil)
            }
        } catch {
            completion([], error)
        }
    }
    
    func importRecords(for date: Date, _ completion: @escaping ((_ error: Error?) -> ())) {
        completionHandler = completion
        
        networkClient.downloadRecords(modelID: modelID, date: date, universityURL: universityURL) { (error) in
            if let error = error {
                self.completionHandler?(error)
            } else {
                self.serializeJSON { (records, error) in
                    if let error = error {
                        self.completionHandler?(error)
                    } else {
                        // New context for sync
                        let taskContext = self.persistentContainer.newBackgroundContext()
                        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                        taskContext.undoManager = nil
                        
                        self.syncRecords(records, taskContext: taskContext)
                    }
                }
            }
        }
    }
    
    func syncRecords(_ json: [[String: Any]], taskContext: NSManagedObjectContext) {
        
    }
}
