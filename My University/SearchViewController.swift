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
    
    private weak var auditoriumDataSource: AuditoriumDataSource?
    private weak var groupDataSource: GroupDataSource?
    private weak var teacherDataSource: TeacherDataSource?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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

        // We want ourselves to be the delegate for this filtered table.
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "groups":
            break
//            let vc = segue.destination as? GroupsViewController
//            groupDataSource = vc?.groupDataSource
            
        case "auditoriums":
            let vc = segue.destination as? AuditoriumsViewController
            auditoriumDataSource = vc?.auditoriumDataSource
            
        case "teachers":
            let vc = segue.destination as? TeachersViewController
            teacherDataSource = vc?.teacherDataSource
            
        case "showGroupSchedule":
            if let destination = segue.destination as? GroupScheduleTableViewController {
                if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                    let selectedGroup = resultsTableController.filteredGroups[indexPath.row]
                    destination.group = selectedGroup
                }
            }
            
        case "showAuditoriumSchedule":
            if let destination = segue.destination as? AuditoriumScheduleTableViewController {
                if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                    let selectedAuditorium = resultsTableController.filteredAuditoriums[indexPath.row]
                    destination.auditorium = selectedAuditorium
                }
            }
            
        case "showTeacherSchedule":
            if let destination = segue.destination as? TeacherScheduleTableViewController {
                if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                    let selectedTeacher = resultsTableController.filteredTeachers[indexPath.row]
                    destination.teacher = selectedTeacher
                }
            }
            
        default:
            break
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

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSourceType {
        case .auditoriums:
            performSegue(withIdentifier: "showAuditoriumSchedule", sender: nil)
        case .groups:
            performSegue(withIdentifier: "showGroupSchedule", sender: nil)
        case .teachers:
            performSegue(withIdentifier: "showTeacherSchedule", sender: nil)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {

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
            guard let searchResults = auditoriumDataSource?.fetchedResultsController?.fetchedObjects else { return }
            
            let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
            
            // Hand over the filtered results to our search results table.
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.filteredAuditoriums = filteredResults
                resultsController.dataSourceType = .auditoriums
                resultsController.tableView.reloadData()
            }
            
        case .groups:
            // Update the filtered array based on the search text.
            guard let searchResults = groupDataSource?.fetchedResultsController?.fetchedObjects else { return }
            
            let filteredResults = searchResults.filter { nameSearchComparisonPredicate.evaluate(with: $0) }
            
            // Hand over the filtered results to our search results table.
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.filteredGroups = filteredResults
                resultsController.dataSourceType = .groups
                resultsController.tableView.reloadData()
            }
            
        case .teachers:
            // Update the filtered array based on the search text.
            guard let searchResults = teacherDataSource?.fetchedResultsController?.fetchedObjects else { return }
            
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


