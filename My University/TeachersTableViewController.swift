//
//  TeachersTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class TeachersTableViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    var university: UniversityEntity?
    private var dataSource: TeacherDataSource?
    
    // MARK: - Notificaion
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        
        if let university = university {
            // Loading teachers
            dataSource = TeacherDataSource(university: university)
            tableView.dataSource = dataSource
            loadTeachers()
        }
    }
    
    // MARK: - Groups
    
    func loadTeachers() {
        guard let dataSource = dataSource else { return }
        dataSource.fetchTeachers()
        
        let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            importTeachers()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
            showTeachersCount()
        }
    }
    
    func importTeachers() {
        guard let dataSource = dataSource else { return }
        
        let text = NSLocalizedString("Loading teachers ...", comment: "")
        showNotification(text: text)
        
        dataSource.importTeachers { (error) in
            if let error = error {
                self.showNotification(text: error.localizedDescription)
            } else {
                self.hideNotification()
            }
            dataSource.fetchTeachers()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.showTeachersCount()
        }
    }
    
    func showTeachersCount() {
        let teachers = dataSource?.fetchedResultsController?.fetchedObjects ?? []
        let text = NSLocalizedString("teachers", comment: "Count of teachers")
        showNotification(text: "\(teachers.count) " + text)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importTeachers()
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .sectionBackgroundColor
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "teacherDetailed", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "teacherDetailed":
            if let detailTableViewController = segue.destination as? TeacherScheduleTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedTeacher = dataSource?.fetchedResultsController?.object(at: indexPath)
                    detailTableViewController.teacher = selectedTeacher
                    detailTableViewController.teacherID = selectedTeacher?.id
                }
            }
            
        default:
            break
        }
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
