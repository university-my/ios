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
        print(url.absoluteString)
        return dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
