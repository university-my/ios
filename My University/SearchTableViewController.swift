//
//  SearchTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit


class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private lazy var auditoriumDataSource: AuditoriumDataSource = {
        return AuditoriumDataSource()
    }()
    
    private lazy var groupDataSource: GroupDataSource = {
        return GroupDataSource()
    }()
    
    private lazy var teacherDataSource: TeacherDataSource = {
        return TeacherDataSource()
    }()
    
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
        
        // Import on pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        
        // Loading...
        loadCurrentDataSource()
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
    
    // MARK: - Pull to refresh
    
    @objc func refreshContent() {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        loadCurrentDataSource()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSourceType {
        case .auditoriums:
            performSegue(withIdentifier: "showAuditoriumSchedule", sender: nil)
        case .groups:
            performSegue(withIdentifier: "showGroupSchedule", sender: nil)
        case .teachers:
            performSegue(withIdentifier: "showTeacherSchedule", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .sectionBackgroundColor
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showGroupSchedule", let destination = segue.destination as? GroupScheduleTableViewController {
            
            var selectedGroup: GroupEntity?
            if tableView == self.tableView, let indexPath = tableView.indexPathForSelectedRow {
                // From main table view
                selectedGroup = groupDataSource.fetchedResultsController?.object(at: indexPath)
                
            } else if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                // From search results controller
                selectedGroup = resultsTableController.filteredGroups[indexPath.row]
            }
            destination.group = selectedGroup
            
        } else if segue.identifier == "showAuditoriumSchedule", let destination = segue.destination as? AuditoriumScheduleTableViewController {
            
            var selectedAuditorium: AuditoriumEntity?
            if tableView == self.tableView, let indexPath = tableView.indexPathForSelectedRow {
                // From main table view
                selectedAuditorium = auditoriumDataSource.fetchedResultsController?.object(at: indexPath)
                
            } else if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                // From search results controller
                selectedAuditorium = resultsTableController.filteredAuditoriums[indexPath.row]
            }
            destination.auditorium = selectedAuditorium
            
        } else if segue.identifier == "showTeacherSchedule", let destination = segue.destination as? TeacherScheduleTableViewController {
            
            var selectedTeacher: TeacherEntity?
            if tableView == self.tableView, let indexPath = tableView.indexPathForSelectedRow {
                // From main table view
                selectedTeacher = teacherDataSource.fetchedResultsController?.object(at: indexPath)
                
            } else if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                // From search results controller
                selectedTeacher = resultsTableController.filteredTeachers[indexPath.row]
            }
            destination.teacher = selectedTeacher
        }
    }
    
    // MARK: - Auditoriums
    
    private func loadAuditoriums()  {
        tableView.dataSource = auditoriumDataSource
        auditoriumDataSource.fetchAuditoriums()
        
        let auditoriums = auditoriumDataSource.fetchedResultsController?.fetchedObjects ?? []
        if auditoriums.isEmpty {
            auditoriumDataSource.importAuditoriums { (error) in
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                self.auditoriumDataSource.fetchAuditoriums()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Groups
    
    private func loadGroups() {
        tableView.dataSource = groupDataSource
        groupDataSource.performFetch()
        
        let groups = groupDataSource.fetchedResultsController?.fetchedObjects ?? []
        if groups.isEmpty {
            groupDataSource.importGroups { (error) in
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                self.groupDataSource.performFetch()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    // MARK: - Teachers
    
    private func loadTeachers() {
        tableView.dataSource = teacherDataSource
        teacherDataSource.fetchTeachers()
        
        let teachers = teacherDataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            teacherDataSource.importTeachers { (error) in
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                self.teacherDataSource.fetchTeachers()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
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
    
    @IBAction func typeChanged(_ sender: Any) {
        loadCurrentDataSource()
    }
    
    private func loadCurrentDataSource() {
        switch dataSourceType {
        case .auditoriums:
            loadAuditoriums()
        case .groups:
            loadGroups()
        case .teachers:
            loadTeachers()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchString = text.trimmingCharacters(in: .whitespaces)
        
        // Name field matching.
        let nameExpression = NSExpression(forKeyPath: "name")
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let nameSearchComparisonPredicate = NSComparisonPredicate(leftExpression: nameExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
        
        switch dataSourceType {
            
        case .auditoriums:
            // Update the filtered array based on the search text.
            guard let searchResults = auditoriumDataSource.fetchedResultsController?.fetchedObjects else { return }
            
            let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
            
            // Hand over the filtered results to our search results table.
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.filteredAuditoriums = filteredResults
                resultsController.dataSourceType = .auditoriums
                resultsController.tableView.reloadData()
            }
            
        case .groups:
            // Update the filtered array based on the search text.
            guard let searchResults = groupDataSource.fetchedResultsController?.fetchedObjects else { return }
            
            let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
            
            // Hand over the filtered results to our search results table.
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.filteredGroups = filteredResults
                resultsController.dataSourceType = .groups
                resultsController.tableView.reloadData()
            }
            
        case .teachers:
            // Update the filtered array based on the search text.
            guard let searchResults = teacherDataSource.fetchedResultsController?.fetchedObjects else { return }
            
            let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
            
            // Hand over the filtered results to our search results table.
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.filteredTeachers = filteredResults
                resultsController.dataSourceType = .teachers
                resultsController.tableView.reloadData()
            }
        }
    }
}
