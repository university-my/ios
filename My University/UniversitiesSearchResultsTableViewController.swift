//
//  UniversitiesSearchResultsTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 25.02.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class UniversitiesSearchResultsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var filtered: [UniversityEntity] = []
    private let searchResultsTableCell = "searchResultsTableCell"
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchResultsTableCell, for: indexPath)
        
        let university = filtered[indexPath.row]
        
        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration {
                UniversityView(university: university.codingData)
            }
        } else {
            // Fallback on earlier versions
            cell.textLabel?.text = university.shortName
            cell.detailTextLabel?.text = university.fullName
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        University.selectedUniversityID = filtered[indexPath.row].id
        performSegue(withIdentifier: "presentUniversity")
    }
}

// MARK: - UISearchResultsUpdating

extension UniversitiesSearchResultsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        guard let text = searchController.searchBar.text else { return }
        let searchQuery = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Hand over the filtered results to our search results table.
        filtered = UniversityEntity.search(with: searchQuery, context: CoreData.shared.viewContext)
        tableView.reloadData()
    }
}
