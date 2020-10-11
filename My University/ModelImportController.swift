//
//  ModelImportController.swift
//  My University
//
//  Created by Yura Voevodin on 11.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class ModelImportController<Kind: ModelKind> {
    
    typealias Model = Kind
    typealias NetworkClient = ModelNetworkClient<Model>
    
    // MARK: - Properties
    
    private let cacheFile: URL
    private let networkClient: NetworkClient
    
    // MARK: - Initialization
    
    init?() {
        let cachesFolder = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        guard let cacheFile = cachesFolder?.appendingPathComponent("\(Model.cashFileName).json") else {
            return nil
        }
        self.cacheFile = cacheFile
        networkClient = NetworkClient(cacheFile: cacheFile)
    }
    
    // MARK: - Methods
    
    func importData(universityURL: String, _ completion: @escaping ((_ json: [[String : Any]], _ error: Error?) -> ())) {
        networkClient.download(universityURL: universityURL) { (error) in
            if let error = error {
                completion([], error)
            } else {
                
                self.serializeJSON(from: self.cacheFile) { (json, error) in
                    completion(json, error)
                }
            }
        }
    }
    
    func serializeJSON(from cacheFile: URL, _ completion: @escaping ((_ json: [[String : Any]], _ error: Error?) -> ())) {
        guard let stream = InputStream(url: cacheFile) else {
            completion([], nil)
            return
        }
        stream.open()
        
        defer {
            stream.close()
        }
        do {
            let object = try JSONSerialization.jsonObject(with: stream, options: []) as? [Any]
            if let json = object as? [[String: Any]] {
                completion(json, nil)
            } else {
                completion([], nil)
            }
        } catch {
            completion([], error)
        }
    }
}
