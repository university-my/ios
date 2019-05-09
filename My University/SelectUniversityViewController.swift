//
//  SelectUniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SelectUniversityViewController: GenericTableViewController {

    // MARK: - Properties

    lazy var dataSource: UniversitiesDataSource = {
        return UniversitiesDataSource()
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        // Loading...
        tableView.dataSource = dataSource
        loadUniversities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNotification()
    }
    
    // MARK: - Universities

    private func loadUniversities() {
        dataSource.fetchUniversities()
        
        let universities = dataSource.fetchedResultsController?.fetchedObjects ?? []
        
        if universities.isEmpty {
            importUniversities()
        } else {
            tableView.reloadData()
        }
    }
    
    private func importUniversities() {
        let text = NSLocalizedString("Loading universities ...", comment: "")
        showNotification(text: text)
        
        dataSource.importUniversities { (error) in
            if let error = error {
                self.refreshControl?.endRefreshing()
                self.showNotification(text: error.localizedDescription)
            } else {
                self.dataSource.fetchUniversities()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.hideNotification()
            }
        }
    }

    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        importUniversities()
    }
    
    // MARK: - Notificaion
    
    @IBOutlet weak var statusButton: UIBarButtonItem!

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showUniversity", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {

        case "showUniversity":
            let destination = segue.destination as? UniversityViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedUniversity = dataSource.fetchedResultsController?.object(at: indexPath)
                destination?.universityID = selectedUniversity?.id
            }

        default:
            break
        }
    }
}
