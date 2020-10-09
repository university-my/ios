//
//  Auditorium+Endpoints.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Auditorium {
    
    struct Endpoints {
        
    }
}

extension Auditorium.Endpoints: PublicWebsitePage {
    static var entityPath: String {
        "auditoriums"
    }
}
