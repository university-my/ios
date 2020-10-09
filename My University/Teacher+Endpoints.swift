//
//  Teacher+Endpoints.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Teacher {
    
    struct Endpoints {
        // Custom endpoints
    }
}

extension Teacher.Endpoints: PublicWebsitePage, EntityEndpoint {
    static var entityPath: String {
        "teachers"
    }
}
