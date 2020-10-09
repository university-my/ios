//
//  EndpointKind.swift
//  My University
//
// https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift
//

import Foundation

protocol EndpointKind {
    associatedtype RequestData
    
    static var url: URL { get }
    
    static func prepare(_ request: inout URLRequest, with data: RequestData)
}

enum EndpointKinds {
    enum API: EndpointKind {
        
        static var url: URL {
            .myUniversityAPI
        }
        
        static func prepare(_ request: inout URLRequest, with token: String) {
        }
    }
    
    enum Public: EndpointKind {
        
        static var url: URL {
            .myUniversity
        }
        
        static func prepare(_ request: inout URLRequest, with _: Void) {
            // Here we can do things like assign a custom cache
            // policy for loading our publicly available data.
            // In this example we're telling URLSession not to
            // use any locally cached data for these requests:
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
    }
}
