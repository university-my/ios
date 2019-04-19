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
    private var groupsDataSource: GroupsDataSource?
    private var teachersDataSource: TeacherDataSource?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title
        title = university?.shortName
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        if let university = university {
            // Init all data sources
            groupsDataSource = GroupsDataSource(university: university)
            teachersDataSource = TeacherDataSource(university: university)
            
            // Start from groups,
            // And import auditoriums and teachers
            loadGroups()
        }
    }
    
    // MARK: - Table
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
        case 1:
            performSegue(withIdentifier: "showTeachers", sender: nil)
            
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
            
        case "showTeachers":
            let vc = segue.destination as? TeachersTableViewController
            vc?.university = university
            
        default:
            break
        }
    }
    
    // MARK: - Groups
    
    private func loadGroups() {
        guard let dataSource = groupsDataSource else { return }
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
    
    // MARK: - Teachers
    
    private func loadTeachers() {
        guard let dataSource = teachersDataSource else { return }
        dataSource.fetchTeachers()
        
        let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            let text = NSLocalizedString("Loading teachers ...", comment: "")
            showNotification(text: text)
            
            dataSource.importTeachers { (error) in
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
