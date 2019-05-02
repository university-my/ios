//
//  AuditoriumsTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/20/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class AuditoriumsTableViewController: SearchableTableViewController {
    
    // MARK: - Properties
    
    var university: UniversityEntity?
    private var dataSource: AuditoriumDataSource?
    
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
            dataSource = AuditoriumDataSource(university: university)
            tableView.dataSource = dataSource
            loadAuditoroums()
        }
    }
    
    // MARK: - Auditoriums
    
    func loadAuditoroums() {
        guard let dataSource = dataSource else { return }
        dataSource.fetchAuditoriums()
        
        let auditoriums = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if auditoriums.isEmpty {
            importAuditoriums()
        } else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
            showAuditoriumsCount()
        }
    }
    
    func importAuditoriums() {
        guard let dataSource = dataSource else { return }
        
        let text = NSLocalizedString("Loading auditoriums ...", comment: "")
        showNotification(text: text)
        
        dataSource.importAuditoriums { (error) in
            if let error = error {
                self.showNotification(text: error.localizedDescription)
            } else {
                self.showAuditoriumsCount()
            }
            dataSource.fetchAuditoriums()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func showAuditoriumsCount() {
        let auditoriums = dataSource?.fetchedResultsController?.fetchedObjects ?? []
        let text = NSLocalizedString("auditoriums", comment: "Count of auditoriums")
        showNotification(text: "\(auditoriums.count) " + text)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        guard !searchController.isActive else {
            refreshControl?.endRefreshing()
            return
        }
        importAuditoriums()
    }
    
    // MARK - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "auditoriumDetailed", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "auditoriumDetailed":
            if let detailTableViewController = segue.destination as? AuditoriumTableViewController {
                if searchController.isActive {
                    if let indexPath = resultsTableController.tableView.indexPathForSelectedRow {
                        let selectedAuditorium = resultsTableController.filteredAuditoriums[safe: indexPath.row]
                        detailTableViewController.auditorium = selectedAuditorium
                        detailTableViewController.auditoriumID = selectedAuditorium?.id
                    }
                } else {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let selectedAuditorium = dataSource?.fetchedResultsController?.object(at: indexPath)
                        detailTableViewController.auditorium = selectedAuditorium
                        detailTableViewController.auditoriumID = selectedAuditorium?.id
                    }
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: - Search
    
    @IBAction func search(_ sender: Any) {
        searchController.searchBar.becomeFirstResponder()
    }
}

// MARK: - UISearchResultsUpdating

extension AuditoriumsTableViewController: UISearchResultsUpdating {
    
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
            resultsController.filteredAuditoriums = filteredResults
            resultsController.dataSourceType = .auditoriums
            resultsController.tableView.reloadData()
        }
    }
}
