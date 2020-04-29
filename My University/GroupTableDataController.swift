//
//  GroupTableDataController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class GroupTableDataController {
    typealias Section = GroupDataController.Section
    
    private(set) var sections: [Section] = []
    
    func update(with newSections: [Section]) {
        sections = newSections
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch sections[section].kind {
        case .noRecords:
            return 1
        case .records(let records, _):
            return records.count
        }
    }
    
    func record(at indexPath: IndexPath) -> Record? {
        let section =  sections[safe: indexPath.section]
        switch section?.kind {
            
        case .none:
            return nil
            
        case .noRecords:
            return nil
            
        case .records(let records, _):
            return records[safe: indexPath.item]
        }
    }
}
