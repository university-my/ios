//
//  Classroom+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Classroom {
    
    struct CodingData: Codable {
        
        // MARK: - Properties
        
        let id: Int64
        let name: String
        let slug: String
    }
}
