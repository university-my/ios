//
//  BaseEndpoint.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

struct BaseEndpoint: EndpointProtocol {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension BaseEndpoint {
    
    static var contacts: Self {
        BaseEndpoint(path: "contacts")
    }
}
