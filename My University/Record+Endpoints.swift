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
        
        static var testLessons: Endpoint<EndpointKinds.API> {
            Endpoint<EndpointKinds.API>(path: "/lessons/test")
        }
        
        /// Testing 500 response with custom code
        static var testLessonsParsingError: Endpoint<EndpointKinds.API> {
            Endpoint<EndpointKinds.API>(path: "/lessons/parsing_error")
        }
    }
}
