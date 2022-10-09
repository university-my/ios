//
//  University+Endpoints.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension University {
    
    struct Endpoints {
        
        static var allUniversities: Endpoint<EndpointKinds.API> {
            Endpoint<EndpointKinds.API>(path: "/universities")
        }
        
        static func logo(name: String) -> Endpoint<EndpointKinds.Public> {
            Endpoint<EndpointKinds.Public>(path: "/\(name)")
        }
    }
}
