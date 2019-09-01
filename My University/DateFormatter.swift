//
//  DateFormatter.swift
//  My University
//
//  Created by Yura Voevodin on 8/31/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var short: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
