//
//  GroupDataController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

class GroupDataController: EntityDataController {
    
    // MARK: - Init
    
    let network: GroupNetworkController
    
    override init() {
        network = GroupNetworkController()
        
        super.init()
        network.delegate = self
    }
    
    // MARK: - Data
    
   override func loadData() {
        guard let groupEntity = group,
            let group = groupEntity.asStruct() else {
            preconditionFailure("Group not found")
        }
        updateDatePredicate()
        fetchRecords()
        buildSections()
        delegate?.entityDataController(didBuildSectionsFor: group)
    }
    
    func importRecords() {
        guard let group = group else {
            preconditionFailure("Group not found")
        }
        // Start import
        isImporting = true
        network.importRecords(for: group, by: pairDate)
    }
    
    // MARK: - Group
    
    private(set) var group: GroupEntity?
    private(set) var groupID: Int64?
    
    func fetchGroup(with id: Int64) {
        groupID = id
        group = GroupEntity.fetch(id: id, context: CoreData.default.viewContext)
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
