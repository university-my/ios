//
//  ClassroomsTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/20/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class ClassroomsTableViewController: SearchableTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    private var dataSource: ClassroomDataSource?
    
    // MARK: - Notification
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        searchController.searchResultsUpdater = self
        
        // Always visible search bar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // This is for reloading data when the favorites are changed
        if let datasource = dataSource {
            datasource.performFetch()
            tableView.reloadData()
        }
        
        // Hide toolbar
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func setup() {
        if let id = universityID {
            dataSource = ClassroomDataSource(universityID: id)
            tableView.dataSource = dataSource
            loadClassrooms()
        }
    }
    
    // MARK: - Classrooms
    
    func loadClassrooms() {
        guard let dataSource = dataSource else { return }
        dataSource.performFetch()
        
        let classrooms = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if classrooms.isEmpty {
            importClassrooms()
        } else if needToUpdateClassrooms() {
            // Update classrooms once in a day
            importClassrooms()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
            hideNotification()
        }
    }
    
    func importClassrooms() {
        guard let dataSource = dataSource else { return }
        
        dataSource.importClassrooms { (error) in

            if let error = error {
                self.showNotification(text: error.localizedDescription)
            } else {
                self.hideNotification()
                
                // Save date of last update
                if let id = self.universityID {
                    UpdateHelper.updated(at: Date(), universityID: id, type: .classroom)
                }
            }
            
            dataSource.performFetch()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.hideNotification()
        }
    }
    
    /// Check last updated date of classrooms
    private func needToUpdateClassrooms() -> Bool {
        guard let id = universityID else { return false }
        let lastSynchronization = UpdateHelper.lastUpdated(for: id, type: .classroom)
        return UpdateHelper.needToUpdate(from: lastSynchronization)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importClassrooms()
    }
    
    // MARK - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .classroomDetails)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case .classroomDetails:
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? ClassroomViewController
            if searchController.isActive {
                if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                    let selectedClassroom = resultsTableController.filteredClassrooms[safe: indexPath.row]
                    vc?.entityID = selectedClassroom?.id
                }
            } else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedClassroom = dataSource?.fetchedResultsController?.object(at: indexPath)
                    vc?.entityID = selectedClassroom?.id
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ClassroomsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchString = text.trimmingCharacters(in: .whitespaces)
        
        // Name field matching.
        let nameExpression = NSExpression(forKeyPath: "name")
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let nameSearchComparisonPredicate = NSComparisonPredicate(leftExpression: nameExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
        
        // Update the filtered array based on the search text.
        guard let searchResults = dataSource?.fetchedResultsController?.fetchedObjects else { return }
        
        let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
        
        // Hand over the filtered results to our search results table.
        if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
            resultsController.filteredClassrooms = filteredResults
            resultsController.dataSourceType = .classrooms
            resultsController.tableView.reloadData()
        }
    }
}

// MARK: - SegueIdentifier

private extension ClassroomsTableViewController.SegueIdentifier {
    static let classroomDetails = "classroomDetails"
}
