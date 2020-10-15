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
    typealias Completion = ((Result<Data, Error>) -> Void)
    
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
    
    func importData(universityURL: String, _ completion: @escaping Completion) {
        let file = cacheFile
        networkClient.download(universityURL: universityURL) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    let data = try Data(contentsOf: file, options: [])
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
