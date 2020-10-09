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
        
//        static var allTeachers: Endpoint<EndpointKinds.Public, NetworkResponse<[Teacher.CodingData]>> {
//            let endpoint = Endpoint<EndpointKinds.Public, NetworkResponse<[Teacher.CodingData]>>(path: "test")
//            return endpoint
//        }
        
    }
    
    
}

extension Teacher.Endpoints: PublicWebsitePage {
    static var entityPath: String {
        "teachers"
    }
}


// Exapmles
// Teacher.Endpoints.allTeachers
// Teacher.Endpoints.allTeachers.request
// Teacher.Endpoints.allTeachers.url
