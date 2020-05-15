//
//  Auditorium+Endpoint.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Auditorium {
    
    struct Endpoint: EndpointProtocol {
        var path: String
        var queryItems: [URLQueryItem] = []
    }
}

extension Auditorium.Endpoint {
    
    static func page(for slug: String, university: String, date: String) -> Self {
        Auditorium.Endpoint(
            path: "/universities/\(university)/auditoriums/\(slug)",
            queryItems: [URLQueryItem(name: "pair_date", value: date)]
        )
    }
}
