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

extension Endpoint {
    
//    func host(for kind: Kind) -> String {
//        
//    }
    
    //    func makeRequest(with kind: Kind) -> URLRequest? {
    //        switch kind {
    //        case is EndpointKinds.Public:
    //            break
    //        default:
    //            break
    //        }
    //    }
    
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
