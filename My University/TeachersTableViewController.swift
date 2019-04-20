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
        searchController.searchResultsUpdater = self
        
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
                self.showTeachersCount()
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
    
    // MARK - Navigation
    
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
