//
//  GroupsTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/18/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var university: UniversityEntity?
    private var groupsDataSource: GroupDataSource?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        
        if let university = university {
            // Loading groups
            groupsDataSource = GroupDataSource(university: university)
            tableView.dataSource = groupsDataSource
            loadGroups()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always display Search Bar.
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Groups
    
    private func loadGroups() {
        guard let dataSource = groupsDataSource else { return }
        dataSource.performFetch()
        
        let groups = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if groups.isEmpty {
            importGroups()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    func importGroups() {
        guard let dataSource = groupsDataSource else { return }
        dataSource.importGroups { (error) in
            if let error = error {
                self.showNotification(text: error.localizedDescription)
            }
            dataSource.performFetch()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Pull to refresh
    
    @objc func refreshContent() {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importGroups()
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
    
    // MARK - Table delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .sectionBackgroundColor
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    // MARK: - Notification
    
    @IBOutlet var notificationView: UIView!
    @IBOutlet weak var notificationLabel: UILabel!
    
    func showNotification(text: String) {
        notificationLabel.text = text
        tableView.tableHeaderView = notificationView
    }
}

// MARK: - UISearchResultsUpdating

extension GroupsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchString = text.trimmingCharacters(in: .whitespaces)
        
        // Name field matching.
        let nameExpression = NSExpression(forKeyPath: "name")
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let nameSearchComparisonPredicate = NSComparisonPredicate(leftExpression: nameExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
        
        // Update the filtered array based on the search text.
        guard let searchResults = groupsDataSource?.fetchedResultsController?.fetchedObjects else { return }
        
        let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
        
        // Hand over the filtered results to our search results table.
        if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
            resultsController.filteredGroups = filteredResults
            resultsController.dataSourceType = .groups
            resultsController.tableView.reloadData()
        }
    }
}
