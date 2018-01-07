//
//  GroupsImportManager.swift
//  Schedule
//
//  Created by Yura Voevodin on 07.01.18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import Foundation

class GroupsImportManager {
    
    // MARK: - Properties
    
    private let cacheFile: URL
    private let groupsAPIClient: GroupsAPIClient
    private var completionHandler: ((_ error: Error?) -> ())?
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init?(context: NSManagedObjectContext) {
        // Cache file
        let cachesFolder = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let cacheFile = cachesFolder?.appendingPathComponent("groups.json") else { return nil }
        self.cacheFile = cacheFile
        
        self.context = context
        
        // API client
        groupsAPIClient = GroupsAPIClient(cacheFile: self.cacheFile)
    }
    
    // MARK: - Import Groups
    
    func importGroups(_ completion: @escaping ((_ error: Error?) -> ())) {
        completionHandler = completion
        
        groupsAPIClient.downloadGroups { (error) in
            if let error = error {
                self.completionHandler?(error)
            } else {
                self.serializeJSON()
            }
        }
    }
    
    private func serializeJSON() {
        guard let stream = InputStream(url: cacheFile) else {
            completionHandler?(nil)
            return
        }
        stream.open()
        
        defer {
            stream.close()
        }
        do {
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
            if let groups = json?["groups"] as? [[String: Any]] {
                parseGroups(groups)
            } else {
                completionHandler?(nil)
            }
        } catch {
            completionHandler?(error)
        }
    }
    
    private func parseGroups(_ json: [[String: Any]]) {
        let parsedGroups = json.flatMap { GroupStruct($0) }
        
        context.perform {
            /*
             Use the overwrite merge policy, because we want any updated objects
             to replace the ones in the store.
             */
            self.context.mergePolicy = NSMergePolicy.overwrite
            
            for group in parsedGroups {
                self.insert(group)
            }
            
            // Finishing import. Save context.
            if self.context.hasChanges {
                do {
                    try self.context.save()
                    self.completionHandler?(nil)
                } catch  {
                    self.completionHandler?(error)
                }
            }
        }
    }
    
    private func insert(_ parsedGroup: GroupStruct) {
        let groupEntitu = GroupEntity(context: context)
        
        if let firstCharacter = parsedGroup.name.first {
            groupEntitu.firstSymbol = String(firstCharacter)
        } else {
            groupEntitu.firstSymbol = ""
        }
        groupEntitu.id = parsedGroup.id
        groupEntitu.name = parsedGroup.name
    }
}
