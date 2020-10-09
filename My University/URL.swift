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
        URL(string: "https://my-university.com.ua")!
    }
    
    static var myUniversityAPI: URL {
        URL.myUniversity.appendingPathComponent("api")
    }
    
    static var contacts: URL {
        URL.myUniversity.appendingPathComponent("contacts")
    }
}
