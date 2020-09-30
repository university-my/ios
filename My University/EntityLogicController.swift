//
//  EntityLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import os
import StoreKit

protocol EntityLogicControllerDelegate: class {
    func didChangeState(to newState: EntityViewController.State)
}

class EntityLogicController: EntityLogicControllerProtocol {
    
    private let logger = Logger(subsystem: Bundle.identifier, category: "EntityLogicController")
    
    // MARK: - Init

    weak var delegate: EntityLogicControllerDelegate?
    private let activityController: ActivityController
    
    init(activity: ActivityController) {
        activityController = activity
    }
    
    // MARK: - Fetch

    /// Override in subclasses
    func fetchData(for entityID: Int64)  {}
    
    func fetchData(controller: EntityDataController) {
        controller.updateDatePredicate()
        controller.fetchRecords()
        
        if controller.needToImportRecords {
            importRecords()
        } else {
            controller.updateSections()
        }
    }
    
    // MARK: - Import
    
    /// Override in subclasses
    func importRecords(showActivity: Bool = true) {}
    
    func importRecords(showActivity: Bool = true, controller: EntityDataController) {
        delegate?.didChangeState(to: .loading(showActivity: showActivity))
        controller.importRecords()
    }
 
    // MARK: - Date
    
    func previousDate(for dataController: EntityDataController) {
        // -1 day
        let currentDate = dataController.pairDate
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            loadRecords(for: previousDate, dataController: dataController)
        }
    }
    
    func nextDate(for dataController: EntityDataController) {
        // +1 day
        let currentDate = dataController.pairDate
        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            loadRecords(for: nextDate, dataController: dataController)
        }
    }
    
    func changePairDate(to newDate: Date, for dataController: EntityDataController) {
        loadRecords(for: newDate, dataController: dataController)
    }
    
    private func loadRecords(for date: Date, dataController: EntityDataController) {
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
    
    func toggleFavorite(_ controller: EntityDataController) {
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

// MARK: - EntityDataControllerDelegate

extension EntityLogicController: EntityDataControllerDelegate {
    
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
