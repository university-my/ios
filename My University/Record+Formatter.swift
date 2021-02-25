//
//  Record+Formatter.swift
//  My University
//
//  Created by Yura Voevodin on 25.02.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    struct Formatter {
        
        /// Make `reason` as multiline string (for universities from ultimate-api)
        static func reason(from record: Record) -> String? {
            record.reason?.replacingOccurrences(of: "; ", with: "\n") ?? nil
        }
    }
}
