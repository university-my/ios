//
//  SearchableTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/20/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SearchableTableViewController: UITableViewController {

    // MARK: - Search
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!

    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController!

    func configureSearchControllers() {

        resultsTableController = storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as? SearchResultsTableViewController

        // Setup the Search Controller.
        searchController = UISearchController(searchResultsController: resultsTableController)

        // Add Search Controller to the navigation item (iOS 11).
        navigationItem.searchController = searchController

        // Setup the Search Bar
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Placeholder in search controller")

        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
}
