//
//  Group+Endpoint.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Group {
    
    struct Endpoint: EndpointProtocol {
        var path: String
        var queryItems: [URLQueryItem] = []
    }
}

extension Group.Endpoint {
    
    static func page(for slug: String, university: String, date: String) -> Self {
        Group.Endpoint(
            path: "/universities/\(university)/groups/\(slug)",
            queryItems: [URLQueryItem(name: "pair_date", value: date)]
        )
    }
}
