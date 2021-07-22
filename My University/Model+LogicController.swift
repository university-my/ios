//
//  Model+LogicController.swift
//  My University
//
//  Created by Yura Voevodin on 18.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import os
import StoreKit

protocol ModelLogicControllerDelegate: AnyObject {
    func didChangeState(to newState: EntityViewController.State)
}

extension Model {
    
    class LogicController {
        
        // MARK: - Properties
        
        private let activityController: ActivityController
        let dataController: DataController
        private let logger = Logger(subsystem: Bundle.identifier, category: "Model.LogicController")
        weak var delegate: ModelLogicControllerDelegate?
        
        // MARK: - Init
        
        init(activity: ActivityController) {
            activityController = activity
            dataController = DataController()
            
            activityController.delegate = self
            dataController.delegate = self
        }
        
        // MARK: - Fetch
        
        var entity: CoreDataEntity? {
            dataController.entity
        }
        
        func fetchData(for entityID: Int64)  {
            dataController.entity = Model.fetch(id: entityID, context: CoreData.default.viewContext)
            fetchData(controller: dataController)
        }
        
        func fetchData(controller: DataController) {
            controller.updateDatePredicate()
            controller.fetchRecords()
            
            if controller.needToImportRecords {
                importRecords()
            } else {
                controller.updateSections()
            }
        }
        
        // MARK: - Import
        
        func importRecords(showActivity: Bool = true) {
            delegate?.didChangeState(to: .loading(showActivity: showActivity))
            dataController.importRecords()
        }
        
        
        var sections: [DataController.Section] {
            return dataController.sections
        }
        
        func shareURL() -> URL? {
            dataController.shareURL(for: dataController.entity)
        }
        
        // MARK: - Date
        
        var pairDate: Date {
            return dataController.pairDate
        }
        
        /// -1 day
        func previousDate() {
            let currentDate = dataController.pairDate
            if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                loadRecords(for: previousDate, dataController: dataController)
            }
        }
        
        /// +1 day
        func nextDate() {
            let currentDate = dataController.pairDate
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                loadRecords(for: nextDate, dataController: dataController)
            }
        }
        
        func changePairDate(to newDate: Date) {
            loadRecords(for: newDate, dataController: dataController)
        }
        
        private func loadRecords(for date: Date, dataController: DataController) {
            // Change date
            dataController.changePairDate(to: date)
            
            // Fetch records
            dataController.updateDatePredicate()
            dataController.fetchRecords()
            
            if dataController.needToImportRecords {
                // Import
                importRecords()
            } else {
                // Build data
                dataController.updateSections()
                
                // Import for update to newer data
                importRecords(showActivity: false)
            }
        }
        
        // MARK: - Favorites
        
        func toggleFavorite(_ controller: DataController) {
            controller.toggleFavorites()
        }
        
        // MARK: - Review Request
        
        func makeReviewRequestIfNeeded() {
            // Get the current bundle version for the app
            let currentVersion = Bundle.appVersion
            
            let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
            
            // If the count has not yet been stored, this will return 0
            let count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.recordDetailsOpenedCountKey)
            
            // Has the process been completed several times and the user has not already been prompted for this version?
            if count >= 4 && currentVersion != lastVersionPromptedForReview {
                let twoSecondsFromNow = DispatchTime.now() + 2.0
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) { [weak self] in
                    
                    self?.logger.info("Make a request for review an app version \(currentVersion)")
                    
                    SKStoreReviewController.requestReview(in: windowScene)
                    UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
                }
            }
        }
    }
}

// MARK: - ModelDataControllerDelegate

extension Model.LogicController: ModelDataControllerDelegate {
    
    func entityDataController(didImportRecordsFor structure: EntityRepresentable, _ error: Error?) {
        if let error = error {
            logger.debug("\(error.localizedDescription)")
            delegate?.didChangeState(to: .failed(error))
        }
    }
    
    func entityDataController(didBuildSectionsFor structure: EntityRepresentable) {
        if activityController.isRunningTransitionAnimation {
            // Do nothing, wait for the animation to finish
            return
        }
        delegate?.didChangeState(to: .presenting(structure))
    }
}


// MARK: - ActivityControllerDelegate

extension Model.LogicController: ActivityControllerDelegate {
    
    func didPresentActivity(from controller: ActivityController) {
        if dataController.isImporting {
            // Do nothing, wait for import
            return
        }
        if let entity = dataController.entity as? StructRepresentable, let data = entity.asStruct()  {
            delegate?.didChangeState(to: .presenting(data))
        }
    }
}
