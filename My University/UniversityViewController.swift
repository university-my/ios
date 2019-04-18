//
//  UniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class UniversityViewController: UITableViewController {

    // MARK: - Properties
    
    var university: UniversityEntity?
    private var groupDataSource: GroupDataSource?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = university?.shortName
        
        if let university = university {
            // Loading groups
            groupDataSource = GroupDataSource(university: university)
            loadGroups()
        }
    }
    
    // MARK: - Table

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
        case 2:
            performSegue(withIdentifier: "showGroups", sender: nil)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return university?.fullName
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showGroups":
            let vc = segue.destination as? GroupsTableViewController
            vc?.university = university
            
        default:
            break
        }
    }
    
    // MARK: - Groups
    
    private func loadGroups() {
        groupDataSource?.performFetch()
        let groups = groupDataSource?.fetchedResultsController?.fetchedObjects ?? []
        
        if groups.isEmpty {
            tableView.isUserInteractionEnabled = false
            
            // Show notification
            let text = NSLocalizedString("Loading groups, please wait ...", comment: "")
            showNotification(text: text, showAcivityIndicator: true)
            
            groupDataSource?.importGroups { (error) in
                if let error = error {
                    self.showNotification(text: error.localizedDescription)
                } else {
//                    self.hideNotification()
                }
//                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
                self.hideNotification()
            }
        }
    }
    
    // MARK: - Notification
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notificationLabel: UILabel!
    
    private func showNotification(text: String, showAcivityIndicator: Bool = false) {
        notificationLabel.text = text
        if showAcivityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        tableView.tableHeaderView = notificationView
    }
    
    private func hideNotification() {
        tableView.beginUpdates()
        tableView.tableHeaderView = nil
        tableView.endUpdates()
    }
}
