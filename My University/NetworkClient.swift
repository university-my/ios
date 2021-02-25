//
//  NetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import Combine

class NetworkClient<Model: Decodable> {
    var urlSession = URLSession.shared
    
    typealias Completion = ((Result<Model, Error>) -> Void)
    
    private var cancellable: Cancellable!
    
    func load(url: URL, decoder: JSONDecoder = .init(), _ completion: @escaping Completion) {
        let publisher = URLSession.shared.publisher(
            for: url,
            responseType: Model.self,
            decoder: decoder
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
