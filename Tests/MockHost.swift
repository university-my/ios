//
//  MockHost.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

struct MockHost {
    
    let host: String
    let apiPrefix: String
    
    var apiURL: String {
        host + apiPrefix
    }
    
    static var localhost: MockHost {
        MockHost(host: "http://localhost:3000", apiPrefix: "/api/v1")
    }
}
