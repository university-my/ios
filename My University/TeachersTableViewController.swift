//
//  TeachersTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class TeachersTableViewController: SearchableTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    private var dataSource: TeacherDataSource?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            // Loading teachers
            dataSource = TeacherDataSource(universityID: id)
            tableView.dataSource = dataSource
            loadTeachers()
        }
    }
    
    // MARK: - Groups
    
    func loadTeachers() {
        guard let dataSource = dataSource else { return }
        dataSource.performFetch()
        
        let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            importTeachers()
        } else if needToUpdateTeachers() {
            // Update teachers once in a day
            importTeachers()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    func importTeachers() {
        guard let dataSource = dataSource else { return }
        
        dataSource.importTeachers { (error) in
            
            #warning("Show alert with error message, like on the Universities screen")
            
            // Save date of last update
            if let id = self.universityID {
                #warning("Move to logic controller")
                UpdateHelper.updated(at: Date(), universityID: id, type: .teacher)
            }
            
            dataSource.performFetch()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    /// Check last updated date of teachers
    private func needToUpdateTeachers() -> Bool {
        #warning("Move to logic controller")
        guard let id = universityID else { return false }
        let lastSynchronisation = UpdateHelper.lastUpdated(for: id, type: .teacher)
        return UpdateHelper.needToUpdate(from: lastSynchronisation)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importTeachers()
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "teacherDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "teacherDetails":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? TeacherViewController
            if searchController.isActive {
                if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                    let selectedTeacher = resultsTableController.filteredTeachers[safe: indexPath.row]
                    vc?.entityID = selectedTeacher?.id
                }
            } else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedTeacher = dataSource?.fetchedResultsController?.object(at: indexPath)
                    vc?.entityID = selectedTeacher?.id
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* It's a common anti-pattern to leave a cell labels populated with their text content when these cells enter the reuse queue.
         */
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
    }
    
    
}

// MARK: - UISearchResultsUpdating

extension TeachersTableViewController: UISearchResultsUpdating {
    
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
            resultsController.filteredTeachers = filteredResults
            resultsController.dataSourceType = .teachers
            resultsController.tableView.reloadData()
        }
    }
}
