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
    
    // MARK: - Message (background view)
    
    let noRecordsMessage = NSLocalizedString("No records", comment: "Message")
    
    func show(message: String) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "TableMessageViewController") as? TableMessageViewController {
            tableView.backgroundView = controller.view
            controller.messageLabel.text = message
        }
    }
    
    func hideMessage() {
        tableView.backgroundView = nil
    }
    
    // MARK: - Activity (background view)
    
    func showActivity() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ActivityViewController") {
            tableView.backgroundView = vc.view
        }
    }
    
    func hideActivity() {
        tableView.backgroundView = nil
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* It's a common anti-pattern to leave a cell labels populated with their text content when these cells enter the reuse queue. */
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
    }
    
    
}
