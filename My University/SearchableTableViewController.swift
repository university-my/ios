//
//  SearchableTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/20/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SearchableTableViewController: UITableViewController {
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController? {
        navigationItem.searchController
    }

    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController? {
        navigationItem.searchController?.searchResultsController as? SearchResultsTableViewController
    }

    func configureSearchControllers(delegate: SearchResultsTableViewControllerDelegate) {
        let results = storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as? SearchResultsTableViewController
        results?.searchResultsDelegate = delegate

        // Add Search Controller to the navigation item
        let controller = UISearchController(searchResultsController: results)
        navigationItem.searchController = controller

        // Setup the Search Bar
        controller.searchBar.placeholder = NSLocalizedString("Search", comment: "Placeholder in search controller")

        controller.isActive = true
        controller.searchBar.becomeFirstResponder()
    }
}
