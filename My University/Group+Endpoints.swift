//
//  Group+Endpoints.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Group {
    
    struct Endpoints {
        // Custom endpoints
    }
}

extension Group.Endpoints: PublicWebsitePage, EntityEndpoint {
    static var entityPath: String {
        "groups"
    }
}
