//
//  GroupDataController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class GroupDataController: EntityDataController {
    
    typealias NetworkController = Model<ModelKinds.GroupModel, GroupEntity>.NetworkController
    
    // MARK: - Init
    
    let network: NetworkController
    
    override init() {
        network = NetworkController()
        
        super.init()
        network.delegate = self
    }
    
    override func importRecords() {
        guard let group = group else {
            preconditionFailure("Group not found")
        }
        // Start import
        isImporting = true
        network.syncRecords(for: group, by: pairDate)
    }
    
    // MARK: - Group
    
    var group: GroupEntity? {
        return entity as? GroupEntity
    }
    
    // MARK: - NSPredicate
    
    override func generatePredicate() -> NSPredicate? {
        guard let group = group else { return nil }
        
        let selectedDate = pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let groupsPredicate = NSPredicate(format: "ANY groups == %@", group)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupsPredicate, datePredicate])
        return compoundPredicate
    }
}
