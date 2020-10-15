//
//  University+NetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation
import Combine

extension University {
    
    class NetworkClient {
        
        typealias Completion = ((Result<[University.CodingData], Error>) -> Void)
        
        private var cancellable: Cancellable!
        
        func loadUniversities(_ completion: @escaping Completion) {
            let url = University.Endpoints.allUniversities.url
            
            let publisher = URLSession.shared.publisher(
                for: url,
                responseType: [University.CodingData].self
            )
            .print("➡️")
            
            cancellable = publisher.sink { (result) in
                
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
    }
}
