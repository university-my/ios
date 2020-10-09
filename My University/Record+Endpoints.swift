//
//  Record+Endpoints.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    struct Endpoints {
        
        static var testRecords: Endpoint<EndpointKinds.API> {
            Endpoint<EndpointKinds.API>(path: "/records/test")
        }
    }
}
