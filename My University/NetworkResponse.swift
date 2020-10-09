//
//  NetworkResponse.swift
//  My University
//
//  https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift
//

import Foundation

struct NetworkResponse<Wrapped: Decodable>: Decodable {
    var result: Wrapped
}
