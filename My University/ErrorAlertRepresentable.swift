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
}

extension ErrorAlertRepresentable where Self: UIViewController {
    
    func present(_ error: Error, tryAgain: @escaping (() -> Void)) {
        present(error, in: self, tryAgain: tryAgain)
    }
}
