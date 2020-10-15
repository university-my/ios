//
//  Teacher+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Teacher {
    
    struct CodingData: Codable {
        
        // MARK: - Properties
        
        let id: Int64
        let name: String
        let slug: String
    }
}
