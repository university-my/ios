//
//  UniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class UniversityViewController: GenericTableViewController {

    // MARK: - Properties
    
    var university: UniversityEntity?
    private var groupDataSource: GroupDataSource?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configurenNotificationLabel()
        statusButton.customView = notificationLabel

        title = university?.shortName
        
        if let university = university {
            // Loading groups
            groupDataSource = GroupDataSource(university: university)
            loadGroups()
        }
    }
    
    // MARK: - Table
    
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
        guard let dataSource = groupDataSource else { return }
        dataSource.performFetch()
        let groups = dataSource.fetchedResultsController?.fetchedObjects ?? []
        
        if groups.isEmpty {
            let text = NSLocalizedString("Loading groups ...", comment: "")
            showNotification(text: text)
            
            dataSource.importGroups { (error) in
                if let error = error {
                    self.showNotification(text: error.localizedDescription)
                } else {
                    self.hideNotification()
                }
            }
        }
    }
    
    // MARK: - Notificaion
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
}
