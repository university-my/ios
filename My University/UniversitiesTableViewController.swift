//
//  UniversitiesTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class UniversitiesTableViewController: GenericTableViewController {
    
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
    }
    
    // MARK: - Universities
    
    private func importUniversities() {
        dataSource.importUniversities { [weak self] (error) in
            if let strongSelf = self {
                if let error = error {
                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.present(error) {
                        // Try again
                        strongSelf.importUniversities()
                    }
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
        performSegue(withIdentifier: .presentUniversity)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension UniversitiesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - ErrorAlertProtocol

extension UniversitiesTableViewController: ErrorAlertRepresentable {}

// MARK: - SegueIdentifier

private extension UniversitiesTableViewController.SegueIdentifier {
    static let presentUniversity = "presentUniversity"
}
