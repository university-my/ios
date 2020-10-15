//
//  Record+NetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import Foundation
import Combine

extension Record {
    
    class NetworkClient<Model: ModelKind> {
        
        typealias Completion = ((Result<Record.RecordsList, Error>) -> Void)
        
        private var recordsCancellable: Cancellable!
        
        func loadRecords(_ params: Record.RequestParameters, _ completion: @escaping Completion) {
            loadRecords(from: Model.recordsEndpoint(params: params), completion)
        }
        
        private func loadRecords(from url: URL, _ completion: @escaping Completion) {
            let publisher = URLSession.shared.publisher(
                for: url,
                responseType: Record.RecordsList.self
            )
            .print("➡️")
            
            recordsCancellable = publisher.sink { (result) in
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
                
            } receiveValue: { data in
                completion(.success(data))
            }
        }

        // MARK: - Tests

        func loadTestRecords(_ completion: @escaping Completion) {
            loadRecords(from: Record.Endpoints.testRecords.url, completion)
        }
    }
}
