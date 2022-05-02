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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        
        // Sear Bar and Search Results Controller
        configureSearchControllers(delegate: self)
        searchController?.searchResultsUpdater = self
        
        // Always visible search bar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // This is for reloading data when the favorites are changed
        if let dataSource = dataSource {
            dataSource.performFetch()
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
        }
    }
    
    func importClassrooms() {
        dataSource?.importClassrooms { [weak self] (error) in
            self?.finishClassroomsImport(with: error)
        }
    }
    
    func finishClassroomsImport(with error: Error?) {
        if let error = error {
            present(error) {
                self.importClassrooms()
            }
        } else if let id = self.universityID {
            // Save date of last update
            UpdateHelper.updated(at: Date(), universityID: id, type: .classroom)
        }
        
        dataSource?.performFetch()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    /// Check last updated date of classrooms
    private func needToUpdateClassrooms() -> Bool {
        guard let id = universityID else { return false }
        let lastSynchronisation = UpdateHelper.lastUpdated(for: id, type: .classroom)
        return UpdateHelper.needToUpdate(from: lastSynchronisation)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !(searchController?.isActive ?? false) else {
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
        
        let navigation = segue.destination as? UINavigationController
        let controller = navigation?.viewControllers.first as? ClassroomViewController
        
        switch identifier {
            
        case .classroomDetails:
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let entity = dataSource?.fetchedResultsController?.object(at: indexPath)
            controller?.entityID = entity?.id
            
        case .classroomDetailsFromSearch:
            guard let indexPath = resultsTableController?.tableView.indexPathForSelectedRow else { return }
            let entity = resultsTableController?.filteredClassrooms[indexPath.row]
            controller?.entityID = entity?.id
            
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

// MARK: - SearchResultsTableViewControllerDelegate

extension ClassroomsTableViewController: SearchResultsTableViewControllerDelegate {
    func searchResultsTableViewController(_ controller: SearchResultsTableViewController, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .classroomDetailsFromSearch)
    }
}

// MARK: - SegueIdentifier

private extension ClassroomsTableViewController.SegueIdentifier {
    static let classroomDetails = "classroomDetails"
    static let classroomDetailsFromSearch = "classroomDetailsFromSearch"
}

// MARK: - ErrorAlertProtocol

extension ClassroomsTableViewController: ErrorAlertRepresentable {}
