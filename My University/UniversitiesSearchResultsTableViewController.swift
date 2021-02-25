//
//  UniversitiesSearchResultsTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 25.02.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit

// MARK: - Cells

private let searchResultsTableCell = "searchResultsTableCell"

class UniversitiesSearchResultsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var filtered: [UniversityEntity] = []
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchResultsTableCell, for: indexPath)
        
        // Configure the cell...
        let university = filtered[indexPath.row]
        cell.textLabel?.text = university.shortName
        cell.detailTextLabel?.text = university.fullName
        
        return cell
    }
    
    
}
