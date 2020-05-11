//
//  GroupLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class GroupLogicController: EntityLogicController {
    
    // MARK: - Init
    
    override init(activity: ActivityController) {
        dataController = GroupDataController()
        
        super.init(activity: activity)
        
        dataController.delegate = self
        activity.delegate = self
    }
    
    // MARK: - Data
    
    private let dataController: GroupDataController
    
    override func fetchData(for entityID: Int64)  {
        dataController.fetchGroup(with: entityID)
        dataController.loadData()
        importRecordsIfNeeded()
    }
    
    override func importRecordsIfNeeded() {
        if dataController.needToImportRecords {
            importRecords()
        }
    }
    
    override func importRecords(showActivity: Bool = true) {
        delegate?.didChangeState(to: .loading(showActivity: showActivity))
        dataController.importRecords()
    }
    
    var sections: [GroupDataController.Section] {
        return dataController.sections
    }
    
    // MARK: - Group
    
    var group: GroupEntity? {
        return dataController.group
    }
    
    // MARK: - Favorites
    
    func toggleFavorite() {
        guard let entity = group else { return }
        dataController.toggleFavorite(for: entity)
        if let group = entity.asStruct() {
            delegate?.didChangeState(to: .presenting(group))
        }
    }
    
    // MARK: - Share URL
    
    func shareURL() -> URL? {
        dataController.shareURL(for: group)
    }
    
    // MARK: - Date
    
    var pairDate: Date {
        return dataController.pairDate
    }
    
    /// -1 day
    func previousDate() {
        previousDate(for: dataController)
    }
    
    /// +1 day
    func nextDate() {
        nextDate(for: dataController)
    }
    
    func changePairDate(to newDate: Date) {
        changePairDate(to: newDate, for: dataController)
    }
}

// MARK: - ActivityControllerDelegate

extension GroupLogicController: ActivityControllerDelegate {
    
    func didPresentActivity(from controller: ActivityController) {
        if dataController.isImporting {
            // Do nothing, wait for import
            return
        }
        
        if let entity = group, let data = entity.asStruct() {
            delegate?.didChangeState(to: .presenting(data))
        }
    }
}
