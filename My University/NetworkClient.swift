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
    
    typealias Completion = ((Result<Model, Error>) -> Void)
    
    func load(_ url: URL, decoder: JSONDecoder, _ completion: @escaping Completion) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        if let appVersion = Bundle.main.shortVersion {
            request.addValue("My University \(appVersion)", forHTTPHeaderField: "User-Agent")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            switch httpResponse.statusCode {
                
            case 404:
                completion(.failure(URLError(.badServerResponse)))
                return
                
            case 500:
                // Check parsing error
                let error = self.decodeNetworkStatus(from: data, with: decoder)
                completion(.failure(error))
                return
                
            default:
                break
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
    
    private func decodeNetworkStatus(from data: Data, with decoder: JSONDecoder) -> Error {
        guard let status = try? decoder.decode(NetworkStatus.CodingData.self, from: data) else {
            return URLError(.badServerResponse)
        }
        
        switch status.code {
        case .scheduleParsingError:
            return NetworkError.scheduleParsingError
        }
    }
}
