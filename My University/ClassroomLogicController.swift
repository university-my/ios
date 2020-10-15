//
//  ClassroomLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

final class ClassroomLogicController: EntityLogicController {
    
    let dataController: ClassroomDataController
    
    // MARK: - Init
    
    override init(activity: ActivityController) {
        dataController = ClassroomDataController()
        
        super.init(activity: activity)
        
        dataController.delegate = self
        activity.delegate = self
    }
    
    // MARK: - Data
    
    override func fetchData(for entityID: Int64) {
        dataController.entity = Classroom.fetch(id: entityID, context: CoreData.default.viewContext)
        fetchData(controller: dataController)
    }
    
    override func importRecords(showActivity: Bool = true) {
        importRecords(showActivity: showActivity, controller: dataController)
    }
    
    var sections: [ClassroomDataController.Section] {
        return dataController.sections
    }
    
    // MARK: - Classroom
    
    var classroom: ClassroomEntity? {
        return dataController.classroom
    }
    
    // MARK: - Share URL
    
    func shareURL() -> URL? {
        dataController.shareURL(for: classroom)
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

extension ClassroomLogicController: ActivityControllerDelegate {
    
    func didPresentActivity(from controller: ActivityController) {
        if dataController.isImporting {
            // Do nothing, wait for import
            return
        }
        if let entity = classroom, let data = entity.asStruct()  {
            delegate?.didChangeState(to: .presenting(data))
        }
    }
}
