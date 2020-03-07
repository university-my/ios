//
//  UniversitiesViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class UniversitiesViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    lazy var dataSource: UniversitiesDataSource = {
        return UniversitiesDataSource()
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        // Loading...
        tableView.dataSource = dataSource
        dataSource.fetchUniversities(delegate: self)
        
        // Import universities every time
        importUniversities()
        
        // Remember date of the first usage
        if UserData.firstUsage == nil {
            UserData.firstUsage = Date()
        }
    }
    
    // MARK: - Universities
    
    private func importUniversities() {
        dataSource.importUniversities { [weak self] (error) in
            if let strongSelf = self {
                if let error = error {
                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.present(error)
                } else {
                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.dataSource.fetchUniversities(delegate: strongSelf)
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        importUniversities()
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let university = dataSource.fetchedResultsController?.fetchedObjects?[safe: indexPath.row]
        University.selectedUniversityID = university?.id
        performSegue(withIdentifier: "setUniversity", sender: nil)
    }

    // MARK: - An error alert

    private func present(_ error: Error) {
        let title = NSLocalizedString("An error occurred", comment: "Alert title")
        let message = error.localizedDescription

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Try again
        let tryAgainTitle = NSLocalizedString("Try again", comment: "Alert action")
        let tryAgainAction = UIAlertAction(title: tryAgainTitle, style: .default) { (_) in
            self.importUniversities()
        }
        alert.addAction(tryAgainAction)

        // Report an error
        let reportAnError = NSLocalizedString("Report an error", comment: "Aler action")
        let reportAction = UIAlertAction(title: reportAnError, style: .default) { (_) in
            if let websiteURL = URL(string: "https://my-university.com.ua/contacts") {
                UIApplication.shared.open(websiteURL)
            }
        }
        alert.addAction(reportAction)

        // Cancel
        let canlel = NSLocalizedString("Cancel", comment: "Alert action")
        let cancelAction = UIAlertAction(title: canlel, style: .cancel)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension UniversitiesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
