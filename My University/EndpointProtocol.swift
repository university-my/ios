//
//  EndpointProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EndpointProtocol {
 
    var path: String { get set }
    var queryItems: [URLQueryItem] { get set }
}

// MARK: - URL

extension EndpointProtocol {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "my-university.com.ua"
        components.path = "/" + path
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        return url
    }
}
