//
//  Teacher+Endpoint.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Teacher {
    
    struct Endpoint: EndpointProtocol {
        var path: String
        var queryItems: [URLQueryItem] = []
    }
}

extension Teacher.Endpoint {
    
    static func page(for slug: String, university: String, date: String) -> Self {
        Teacher.Endpoint(
            path: "/universities/\(university)/teachers/\(slug)",
            queryItems: [URLQueryItem(name: "pair_date", value: date)]
        )
    }
}
