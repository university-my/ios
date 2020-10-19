//
//  EndpointKind.swift
//  My University
//
// https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift
//

import Foundation

protocol EndpointKind {
    static var url: URL { get }
}

enum EndpointKinds {
    enum API: EndpointKind {
        
        static var url: URL {
            .myUniversityAPI
        }
    }
    
    enum Public: EndpointKind {
        
        static var url: URL {
            .myUniversity
        }
    }
}
