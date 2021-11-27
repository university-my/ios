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
    
    func loadWithPublisher(url: URL, decoder: JSONDecoder = .init(), _ completion: @escaping Completion) {
        let publisher = urlSession.publisher(
            for: url,
            responseType: Model.self,
            decoder: decoder
        )
        
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
    
    func load(_ url: URL, decoder: JSONDecoder, _ completion: @escaping Completion) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError(kind: .dataNotFound)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    // Check parsing error
                    let error = URLSession.decodeNetworkStatus(from: data, with: decoder)
                    completion(.failure(error))
                }
            }
            
            let result = self.decodeModel(from: data, with: decoder)
            completion(result)
        }
        task.resume()
    }
    
    private func decodeModel(from data: Data, with decoder: JSONDecoder) -> Result<Model, Error> {
        do {
            let decodedData = try decoder.decode(Model.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(error)
        }
    }
}
