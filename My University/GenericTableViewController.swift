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

    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    // MARK: - Notification
    
    var notificationLabel = UILabel(frame: CGRect.zero)
    
    func configureNotificationLabel() {
        notificationLabel.sizeToFit()
        notificationLabel.backgroundColor = .clear
        notificationLabel.textAlignment = .center
        notificationLabel.textColor = .lightGray
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
}
