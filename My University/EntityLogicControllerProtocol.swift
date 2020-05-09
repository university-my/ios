//
//  EntityLogicControllerProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityLogicControllerProtocol {
    
    func fetchData(for entityID: Int64)
    func importRecords(showActivity: Bool)
}
