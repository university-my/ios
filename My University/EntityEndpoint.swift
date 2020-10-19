//
//  EntityEndpoint.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityEndpoint {
    static var entityPath: String { get }
}

extension EntityEndpoint {
    
    static func all(university: String) -> Endpoint<EndpointKinds.API> {
        Endpoint<EndpointKinds.API>(
            path: "/universities/\(university)/\(entityPath)"
        )
    }
    
    static func records(params: Record.RequestParameters) -> Endpoint<EndpointKinds.API> {
        Endpoint<EndpointKinds.API>(
            path: "/universities/\(params.university)/\(entityPath)/\(params.id)/records",
            queryItems: [
                URLQueryItem(name: "pair_date", value: params.date)
            ]
        )
    }
}
