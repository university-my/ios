//
//  GenericTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

class GenericTableViewController: UITableViewController {
    
    // MARK: - Notification (toolbar)
    
    var notificationLabel = UILabel(frame: CGRect.zero)
    
    func configureNotificationLabel() {
        notificationLabel.sizeToFit()
        notificationLabel.backgroundColor = .clear
        notificationLabel.textAlignment = .center
      notificationLabel.textColor = .systemBlue
        notificationLabel.adjustsFontSizeToFitWidth = true
        notificationLabel.minimumScaleFactor = 0.5
    }
    
    func showNotification(text: String?) {
        notificationLabel.text = text
        notificationLabel.sizeToFit()
    }
    
    func hideNotification() {
        notificationLabel.text = nil
    }
    
    // MARK: - Message (backgroud view)
    
    let noRecordsMessage = NSLocalizedString("No records", comment: "Message")
    
    func show(message: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TableMessageViewController") as? TableMessageViewController {
            tableView.backgroundView = vc.view
            vc.messageLabel.text = message
        }
    }
    
    func hideMessage() {
        tableView.backgroundView = nil
    }
    
    // MARK: - Activity (backgroud view)
    
    func showActivity() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ActivityViewController") {
            tableView.backgroundView = vc.view
        }
    }
    
    func hideActivity() {
        tableView.backgroundView = nil
    }
}
