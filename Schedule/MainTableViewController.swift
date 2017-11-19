//
//  MainTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.06.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class MainTableViewController: UITableViewController {
    
    // MARK: - Lifecycle
    
    // TODO: Handle errors from Operations
    // TODO: Check without Interner connection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        
        // Import on pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        
        // Fetch or import data
        performFetch()
        let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
        if  fetchedObjects.isEmpty {
            importGroups()
        } else {
            updateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always display Search Bar.
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        return section?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        // Configure cell
        if let group = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = group.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailed", sender: nil)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return namesOfSections
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailed", let detailTableViewController = segue.destination as? DetailTableViewController {
            var selectedGroup: GroupEntity?
            
            if tableView == self.tableView, let indexPath = tableView.indexPathForSelectedRow {
                // From main table view
                selectedGroup = fetchedResultsController?.object(at: indexPath)
            } else if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                // From search results controller
                selectedGroup = resultsTableController.filteredGroups[indexPath.row]
            }
            detailTableViewController.group = selectedGroup
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<GroupEntity>? = {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "firstSymbol", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        ]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "firstSymbol", cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
            collectNamesOfSections()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    private var namesOfSections: [String] = []
    
    private func collectNamesOfSections() {
        var names: [String] = []
        if let sections = fetchedResultsController?.sections {
            for section in sections {
                names.append(section.name)
            }
        }
        namesOfSections = names
    }
    
    // MARK: - Operation Queue
    
    private let queue = OperationQueue()
    
    private func importGroups() {
        // Do nothing without CoreData.
        guard let context = viewContext else { return }
        
        let getGroupsOperation = GetGroupsOperation(context: context) {
            DispatchQueue.main.async {
                self.performFetch()
                self.updateUI()
            }
        }
        if let getGroups = getGroupsOperation {
            queue.addOperation(getGroups)
        }
    }
    
    // MARK: - Search
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController!
    
    private func configureSearchControllers() {
        
        resultsTableController = storyboard!.instantiateViewController(withIdentifier: "searchResultsTableViewController") as! SearchResultsTableViewController
        
        // We want ourselves to be the delegate for this filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        // Setup the Search Controller.
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        
        // Add Search Controller to the navigation item (iOS 11).
        navigationItem.searchController = searchController
        
        // Setup the Search Bar
        searchController.searchBar.setValue("Скасувати", forKey:"_cancelButtonText")
        searchController.searchBar.placeholder = "Пошук"
        
        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = true
        
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    @objc func refreshContent() {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importGroups()
    }
    
    private func updateUI() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

// MARK: - UISearchResultsUpdating

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchString = text.trimmingCharacters(in: .whitespaces)
        
        // Update the filtered array based on the search text.
        guard let searchResults = fetchedResultsController?.fetchedObjects else { return }
        
        // Name field matching.
        let nameExpression = NSExpression(forKeyPath: "name")
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let nameSearchComparisonPredicate = NSComparisonPredicate(leftExpression: nameExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
        
        let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
        
        // Hand over the filtered results to our search results table.
        if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
            resultsController.filteredGroups = filteredResults
            resultsController.tableView.reloadData()
        }
    }
}
