//
//  SearchViewController.swift
//  My University
//
//  Created by Yura Voevodin on 3/27/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

enum DataSourceType: Int {
    case groups = 0, auditoriums, teachers
}

class SearchViewController: UIViewController {

     // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true

        // Sear Bar and Search Results Controller
        configureSearchControllers()

        showCurrentContainer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Always display Search Bar.
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Search

    /// Search controller to help us with filtering.
    var searchController: UISearchController!

    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController!

    private func configureSearchControllers() {

        resultsTableController = storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as? SearchResultsTableViewController

        // We want ourselves to be the delegate for this filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self

        // Setup the Search Controller.
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .orange
        searchController.searchBar.keyboardAppearance = .dark

        // Add Search Controller to the navigation item (iOS 11).
        navigationItem.searchController = searchController

        // Setup the Search Bar
        searchController.searchBar.setValue(NSLocalizedString("Cancel", comment: "Cancel search"), forKey:"_cancelButtonText")
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

    // MARK: - UISegmentedControl

    var dataSourceType: DataSourceType {
        get {
            if let type = DataSourceType(rawValue: segmentedControl.selectedSegmentIndex) {
                return type
            } else {
                return .groups
            }
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var auditoriumsContainer: UIView!
    @IBOutlet weak var groupsContainer: UIView!
    @IBOutlet weak var teachersContainer: UIView!

    @IBAction func typeChanged(_ sender: Any) {
        showCurrentContainer()
    }

    private func showCurrentContainer() {
        switch dataSourceType {

        case .auditoriums:
            auditoriumsContainer.isHidden = false
            groupsContainer.isHidden = true
            teachersContainer.isHidden = true

        case .groups:
            groupsContainer.isHidden = false
            auditoriumsContainer.isHidden = true
            teachersContainer.isHidden = true

        case .teachers:
            teachersContainer.isHidden = false
            groupsContainer.isHidden = true
            auditoriumsContainer.isHidden = true
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
