//
//  EndpointKind.swift
//  My University
//
// https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift
//

import Foundation

protocol EndpointKind {
    associatedtype RequestData
    
    static func prepare(_ request: inout URLRequest, with data: RequestData)
}

enum EndpointKinds {
    enum Public: EndpointKind {
        static func prepare(_ request: inout URLRequest, with _: Void) {
            // Here we can do things like assign a custom cache
            // policy for loading our publicly available data.
            // In this example we're telling URLSession not to
            // use any locally cached data for these requests:
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
    }

    enum Private: EndpointKind {
        static func prepare(_ request: inout URLRequest, with token: String) {
            // For our private endpoints, we'll require an
            // access token to be passed, which we then use to
            // assign an Authorization header to each request:
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
