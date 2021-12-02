//
//  NetworkError.swift
//  My University
//
//  Created by Yura Voevodin on 25.11.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

struct NetworkStatus {}

extension NetworkStatus {
    
    enum Code: String, Codable {
        case scheduleParsingError = "1001"
    }
    
    struct CodingData: Codable {
        let error: String
        let code: Code
    }
}
