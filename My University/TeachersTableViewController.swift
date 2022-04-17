//
//  TeachersTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class TeachersTableViewController: SearchableTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    private var dataSource: TeacherDataSource?
    private let logic: TeachersLogicController
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = TeachersLogicController()
        
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure table
        tableView.rowHeight = UITableView.automaticDimension

        // Sear Bar and Search Results Controller
        configureSearchControllers()
        resultsTableController.searchResultsDelegate = self
        
        searchController.searchResultsUpdater = self
        
        // Always visible search bar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        // This is for reloading data when the favourites are changed
        if let dataSource = dataSource {
            dataSource.performFetch()
            tableView.reloadData()
        }
        
        // Hide toolbar
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func setup() {
        if let id = universityID {
            // Loading teachers
            dataSource = TeacherDataSource(universityID: id)
            logic.update(with: id, dataSource: dataSource)
            tableView.dataSource = dataSource
            loadTeachers()
        }
    }
    
    // MARK: - Load
    
    func loadTeachers() {
        if logic.needToImportTeachers() {
            importTeachers()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    func importTeachers() {
        logic.importTeachers { (error) in
            self.finishTeachersImport(with: error)
        }
    }
    
    func finishTeachersImport(with error: Error?) {
        if let error = error {
            present(error) {
                self.importTeachers()
            }
        }
        dataSource?.performFetch()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importTeachers()
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .teacherDetails)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case .teacherDetails:
            let navigation = segue.destination as? UINavigationController
            let controller = navigation?.viewControllers.first as? TeacherViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedTeacher = dataSource?.fetchedResultsController?.object(at: indexPath)
                controller?.entityID = selectedTeacher?.id
            }
            
        case .teacherDetailsFromSearch:
            let navigation = segue.destination as? UINavigationController
            let controller = navigation?.viewControllers.first as? TeacherViewController
            if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                let teacher = resultsTableController.filteredTeachers[indexPath.row]
                controller?.entityID = teacher.id
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

// MARK: - SearchResultsTableViewControllerDelegate

extension TeachersTableViewController: SearchResultsTableViewControllerDelegate {
    func searchResultsTableViewController(_ controller: SearchResultsTableViewController, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .teacherDetailsFromSearch)
    }
}

// MARK: - ErrorAlertProtocol

extension TeachersTableViewController: ErrorAlertRepresentable {}

// MARK: - SegueIdentifier

private extension TeachersTableViewController.SegueIdentifier {
    static let teacherDetails = "teacherDetails"
    static let teacherDetailsFromSearch = "teacherDetailsFromSearch"
}
