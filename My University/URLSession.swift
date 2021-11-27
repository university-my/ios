//
//  URLSession.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import Combine

extension URLSession {
    
    func publisher<T: Decodable>(for url: URL, responseType: T.Type = T.self, decoder: JSONDecoder = .init()) -> AnyPublisher<T, Error> {
        dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 404 {
                    // Check parsing error
                    let error = URLSession.decodeNetworkStatus(from: element.data, with: decoder)
                    throw error
                }
                return element.data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    static func decodeNetworkStatus(from data: Data, with decoder: JSONDecoder) -> Error {
        do {
            let status = try decoder.decode(NetworkStatus.CodingData.self, from: data)
            
            switch status.code {
            case .scheduleParsingError:
                return NetworkError(kind: .scheduleParsingError)
            }
            
        } catch {
            return error
        }
    }
}
