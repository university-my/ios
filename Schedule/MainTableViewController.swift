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
    
    // MARK: - Properties
    
    private lazy var fetchedResultsController: NSFetchedResultsController<GroupEntity>? = {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "firstSymbol", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
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
    
    let queue = OperationQueue()
    
    // MARK: Search
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    /// Secondary search results table view.
    var resultsTableController: SearchResultsTableViewController!
    
    // MARK: - Lifecycle
    
    // TODO: Handle errors from Operations
    // TODO: Check without Interner connection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do nothing without CoreData.
        guard let context = viewContext else { return }
        
        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true
        
        /*
         Configure search controllers
         */
        resultsTableController = SearchResultsTableViewController()
        
        // We want ourselves to be the delegate for this filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        // Setup the Search Controller
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self

        // Add Search Controller to the navigation item (iOS 11)
        navigationItem.searchController = searchController
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        
        // Setup the Search Bar
        searchController.searchBar.placeholder = "Знайти групу"
        searchController.searchBar.delegate = self    // so we can monitor text changes + others7
        
        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = true
        
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        
        /*
         Fetch or import data
         */
        performFetch()
        let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
        if  fetchedObjects.isEmpty {
            
            if let getGroups = GetGroupsOperation(context: context, completionHandler: {
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }) {
                queue.addOperation(getGroups)
            }
        } else {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
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
        
        if let group = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = group.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
}

// MARK: - UISearchBarDelegate

extension MainTableViewController: UISearchBarDelegate {
    
}

// MARK: - UISearchControllerDelegate

extension MainTableViewController: UISearchControllerDelegate {
    
}

// MARK: - UISearchResultsUpdating

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: - Helpers

extension MainTableViewController {
    
    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    private func updateUI() {
        performFetch()
        tableView.reloadData()
    }
}
