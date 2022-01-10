//
//  ErrorAlertProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

protocol ErrorAlertRepresentable {}

extension ErrorAlertRepresentable {
    
     func present(_ error: Error, in viewController: UIViewController, tryAgain: @escaping (() -> Void)) {
        let title = NSLocalizedString("An error occurred", comment: "Alert title")
        let message = error.localizedDescription
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemIndigo
        
        // Try again
        let tryAgainTitle = NSLocalizedString("Try again", comment: "Alert action")
        let tryAgainAction = UIAlertAction(title: tryAgainTitle, style: .default) { (_) in
            tryAgain()
        }
        alert.addAction(tryAgainAction)
        
        // Report an error
         alert.addAction(reportErrorAction())
        
        // Cancel
        let canсel = NSLocalizedString("Cancel", comment: "Alert action")
        let cancelAction = UIAlertAction(title: canсel, style: .cancel)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - Parsing Error
    
    
    /// Show this alert when the schedule parsing error coming from API
    /// - Parameters:
    ///   - error: Custom network error
    ///   - website: URL to the page on the My University website (exact URL to the entity with selected date)
    func configureParsingErrorAlert(with error: NetworkError, website: URL?) -> UIAlertController {
        let title = NSLocalizedString("An error occurred", comment: "Alert title")
        let message = error.localizedDescription
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemIndigo
        
        if let website = website {
            let checkOnWebsite = NSLocalizedString("Check on website", comment: "Alert action")
            let action = UIAlertAction(title: checkOnWebsite, style: .cancel) { _ in
                UIApplication.shared.open(website)
            }
            alert.addAction(action)
        }
        
        // Report an error
        alert.addAction(reportErrorAction())
        
        // Cancel
        let canсel = NSLocalizedString("Cancel", comment: "Alert action")
        let cancelAction = UIAlertAction(title: canсel, style: .destructive)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    func configureNotFoundAlert() -> UIAlertController {
        let title = NSLocalizedString("Sorry", comment: "Alert title")
        let message = NSLocalizedString("We cannot found this schedule anymore. We know this is a bad case. To fix this try to reinstall an app.", comment: "Alert message")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemIndigo
        
        // Report an error
        alert.addAction(reportErrorAction())
        
        let okActionTitle = NSLocalizedString("OK", comment: "Alert action")
        let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
    
    func reportErrorAction() -> UIAlertAction {
        let reportAnError = NSLocalizedString("Report an error", comment: "Alert action")
        let reportAction = UIAlertAction(title: reportAnError, style: .default) { (_) in
            UIApplication.shared.open(.contacts)
        }
        return reportAction
    }
    
    // MARK: - UUID not found
    
    func configureUUIDNotFoundAlert(with error: LogicError, reload: @escaping (() -> Void)) -> UIAlertController {
        let title = NSLocalizedString("An error occurred", comment: "Alert title")
        let message = error.localizedDescription
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemIndigo
        
        // Reload
        let reloadTitle = NSLocalizedString("Reload list", comment: "Alert action")
        let reloadAction = UIAlertAction(title: reloadTitle, style: .cancel) { (_) in
            reload()
        }
        alert.addAction(reloadAction)
        
        // Cancel
        let canсel = NSLocalizedString("Cancel", comment: "Alert action")
        let cancelAction = UIAlertAction(title: canсel, style: .destructive)
        alert.addAction(cancelAction)
        
        return alert
    }
}

extension ErrorAlertRepresentable where Self: UIViewController {
    
    func present(_ error: Error, tryAgain: @escaping (() -> Void)) {
        present(error, in: self, tryAgain: tryAgain)
    }
}
