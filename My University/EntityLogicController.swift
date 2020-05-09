//
//  EntityLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol EntityLogicControllerDelegate: class {
    func didChangeState(to newState: EntityViewController.State)
}

class EntityLogicController: EntityLogicControllerProtocol {
    
    // MARK: - Init

    weak var delegate: EntityLogicControllerDelegate?
    private let activityController: ActivityController
    
    init(activity: ActivityController) {
        activityController = activity
    }
    
    // MARK: - Data
    
    /// Override in subclasses
    func fetchData(for entityID: Int64)  {}
    
    /// Override in subclasses
    func importRecords(showActivity: Bool = true) {}
    
    /// Override in subclasses
    func importRecordsIfNeeded() {}
 
    // MARK: - Date
    
    func previousDate(for dataController: EntityDataController) {
        // -1 day
        let currentDate = dataController.pairDate
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            dataController.changePairDate(to: previousDate)
            importRecordsIfNeeded()
        }
    }
    
    func nextDate(for dataController: EntityDataController) {
        // +1 day
        let currentDate = dataController.pairDate
        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            dataController.changePairDate(to: nextDate)
            importRecordsIfNeeded()
        }
    }
    
    func changePairDate(to newDate: Date, for dataController: EntityDataController) {
        dataController.changePairDate(to: newDate)
        importRecordsIfNeeded()
    }
}

// MARK: - EntityDataControllerDelegate

extension EntityLogicController: EntityDataControllerDelegate {
    
    func entityDataController(didImportRecordsFor structure: EntityStructRepresentable, _ error: Error?) {
        if let error = error {
            delegate?.didChangeState(to: .failed(error))
        }
    }
    
    func entityDataController(didBuildSectionsFor structure: EntityStructRepresentable) {
        if activityController.isRunningTransitionAnimation {
            // Do nothing, wait for the animation to finish
            return
        }
        delegate?.didChangeState(to: .presenting(structure))
    }
}
