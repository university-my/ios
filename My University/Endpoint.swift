//
//  Endpoint.swift
//  My University
//
//  https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift
//

import Foundation

struct Endpoint<Kind: EndpointKind> {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        let url = Kind.url
        
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.port = url.port
        components.path = url.path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard var newURL = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        // Endpoint path
        newURL.appendPathComponent(path)
        
        return newURL
    }
}

extension Endpoint {
    
    func makeRequest(with data: Kind.RequestData) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "my-university.com.ua"
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        // If either the path or the query items passed contained
        // invalid characters, we'll get a nil URL back:
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        Kind.prepare(&request, with: data)
        return request
    }
}
