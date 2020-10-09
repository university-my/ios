//
//  URL.swift
//  My University
//
//  Created by Yura Voevodin on 08.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension URL {
    
    static var myUniversity: URL {
        let scheme = Bundle.main.infoDictionary?["MY_UNIVERSITY_SERVER_SCHEME"] as! String
        let host = Bundle.main.infoDictionary?["MY_UNIVERSITY_SERVER_HOST"] as! String
        let port = Bundle.main.infoDictionary?["MY_UNIVERSITY_SERVER_PORT"] as! String
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = Int(port)
        guard let url = components.url else {
            preconditionFailure()
        }
        return url
    }
    
    static var myUniversityAPI: URL {
        let prefix = Bundle.main.infoDictionary?["MY_UNIVERSITY_API_PREFIX_V1"] as! String
        return URL.myUniversity.appendingPathComponent(prefix)
    }
    
    static var contacts: URL {
        URL.myUniversity.appendingPathComponent("contacts")
    }
}
