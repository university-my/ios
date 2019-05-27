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
    
    var universityID: Int64?
    private var dataSource: AuditoriumDataSource?
    var showFavorites: Bool = false
    
    // MARK: - Notificaion
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        
        // Sear Bar and Search Results Controller
        configureSearchControllers()
        searchController.searchResultsUpdater = self
        
        selectFavorites(favoritesButton, show: showFavorites)
        
        setup()
    }
    
    func setup() {
        if let id = universityID {
            dataSource = AuditoriumDataSource(universityID: id)
            tableView.dataSource = dataSource
            loadAuditoroums()
        }
    }
    
    // MARK: - Favorites
    
    @IBAction func showFavorites(_ sender: Any) {
        if let id = universityID {
            dataSource = AuditoriumDataSource(universityID: id)
            tableView.dataSource = dataSource
        }
        if showFavorites == false {
            showFavorites = true
            if let datasource = dataSource {
                datasource.predicate = NSPredicate(format: "university == %@ AND favorite == YES", datasource.university)
            }
        } else {
            showFavorites = false
            if let datasource = dataSource {
                datasource.predicate = NSPredicate(format: "university == %@", datasource.university)
            }
        }
        selectFavorites(favoritesButton, show: showFavorites)
        loadAuditoroums()
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
            hideNotification()
        }
    }
    
    func importAuditoriums() {
        guard let dataSource = dataSource else { return }
        
        let text = NSLocalizedString("Loading auditoriums ...", comment: "")
        showNotification(text: text)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        dataSource.importAuditoriums { (error) in

            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if let error = error {
                self.showNotification(text: error.localizedDescription)
            } else {
                self.hideNotification()
            }
            dataSource.fetchAuditoriums()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
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
                        detailTableViewController.auditoriumID = selectedAuditorium?.id
                        detailTableViewController.isFavorite = selectedAuditorium?.favorite ?? false
                    }
                } else {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let selectedAuditorium = dataSource?.fetchedResultsController?.object(at: indexPath)
                        detailTableViewController.auditoriumID = selectedAuditorium?.id
                        detailTableViewController.isFavorite = selectedAuditorium?.favorite ?? false
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

// MARK: - UIStateRestoring

extension AuditoriumsTableViewController {

  override func encodeRestorableState(with coder: NSCoder) {
    if let id = universityID {
      coder.encode(id, forKey: "universityID")
    }
    super.encodeRestorableState(with: coder)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    universityID = coder.decodeInt64(forKey: "universityID")
  }
    
    override func applicationFinishedRestoringState() {
        setup()
    }
}
