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
        let reportAnError = NSLocalizedString("Report an error", comment: "Alert action")
        let reportAction = UIAlertAction(title: reportAnError, style: .default) { (_) in
            UIApplication.shared.open(.contacts)
        }
        alert.addAction(reportAction)
        
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
            let checkOnWebsite = String(localized: "Check on website")
            let action = UIAlertAction(title: checkOnWebsite, style: .default) { _ in
                UIApplication.shared.open(website)
            }
            action.setValue(UIColor.systemGreen, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        // Report an error
        let reportAnError = NSLocalizedString("Report an error", comment: "Alert action")
        let reportAction = UIAlertAction(title: reportAnError, style: .default) { (_) in
            UIApplication.shared.open(.contacts)
        }
        alert.addAction(reportAction)
        
        // Cancel
        let canсel = NSLocalizedString("Cancel", comment: "Alert action")
        let cancelAction = UIAlertAction(title: canсel, style: .cancel)
        alert.addAction(cancelAction)
        
        return alert
    }
}

extension ErrorAlertRepresentable where Self: UIViewController {
    
    func present(_ error: Error, tryAgain: @escaping (() -> Void)) {
        present(error, in: self, tryAgain: tryAgain)
    }
}
