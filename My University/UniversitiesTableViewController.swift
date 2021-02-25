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
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        searchController.searchResultsUpdater = self
        
        // Always visible search bar
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
    
    // MARK: - Search
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!

    /// Secondary search results table view.
    var resultsTableController: UniversitiesSearchResultsTableViewController!

    func configureSearchControllers() {

        resultsTableController = storyboard!.instantiateViewController(withIdentifier: "UniversitiesSearchResultsTableViewController") as? UniversitiesSearchResultsTableViewController

        // We want ourselves to be the delegate for this filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self

        // Setup the Search Controller.
        searchController = UISearchController(searchResultsController: resultsTableController)

        // Add Search Controller to the navigation item (iOS 11).
        navigationItem.searchController = searchController

        // Setup the Search Bar
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Placeholder in search controller")

        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = true

        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
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

// MARK: - UISearchResultsUpdating

extension UniversitiesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchString = text.trimmingCharacters(in: .whitespaces)
        
        let filteredResults = UniversityEntity.search(with: searchString, context: CoreData.default.viewContext)
        
        // Hand over the filtered results to our search results table.
        if let resultsController = searchController.searchResultsController as? UniversitiesSearchResultsTableViewController {
            resultsController.filtered = filteredResults
            resultsController.tableView.reloadData()
        }
    }
}
