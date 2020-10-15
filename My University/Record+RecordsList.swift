//
//  Record+RecordsList.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {

    struct RecordsList: Codable {
        let records: [Record.CodingData]
    }
}
