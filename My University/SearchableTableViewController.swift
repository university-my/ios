//
//  SearchableTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/20/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SearchableTableViewController: GenericTableViewController {

    // MARK: - Search
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!

    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController!

    func configureSearchControllers() {

        resultsTableController = storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as? SearchResultsTableViewController

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
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* It's a common anti-pattern to leave a cell labels populated with their text content when these cells enter the reuse queue. */
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
    }
    
    
}
