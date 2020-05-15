//
//  AuditoriumLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class AuditoriumLogicController: EntityLogicController {
    
    let dataController: AuditoriumDataController
    
    // MARK: - Init
    
    override init(activity: ActivityController) {
        dataController = AuditoriumDataController()
        
        super.init(activity: activity)
        
        dataController.delegate = self
        activity.delegate = self
    }
    
    // MARK: - Data
    
    override func fetchData(for entityID: Int64) {
        dataController.entity = AuditoriumEntity.fetch(id: entityID, context: CoreData.default.viewContext)
        fetchData(controller: dataController)
    }
    
    override func importRecords(showActivity: Bool = true) {
        importRecords(showActivity: showActivity, controller: dataController)
    }
    
    var sections: [AuditoriumDataController.Section] {
        return dataController.sections
    }
    
    // MARK: - Auditorium
    
    var auditorium: AuditoriumEntity? {
        return dataController.auditorium
    }
    
    // MARK: - Share URL
    
    func shareURL() -> URL? {
        dataController.shareURL(for: auditorium)
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

extension AuditoriumLogicController: ActivityControllerDelegate {
    
    func didPresentActivity(from controller: ActivityController) {
        if dataController.isImporting {
            // Do nothing, wait for import
            return
        }
        if let entity = auditorium, let data = entity.asStruct()  {
            delegate?.didChangeState(to: .presenting(data))
        }
    }
}
