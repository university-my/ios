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
                if let _ = error {
                    strongSelf.refreshControl?.endRefreshing()
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
}

// MARK: - NSFetchedResultsControllerDelegate

extension UniversitiesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
