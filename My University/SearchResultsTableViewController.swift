//
//  SearchResultsTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 16.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

enum DataSourceType: Int {
    case groups = 0, auditoriums, teachers
}

class SearchResultsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var dataSourceType: DataSourceType = .auditoriums
    
    var filteredGroups: [GroupEntity] = []
    var filteredAuditoriums: [AuditoriumEntity] = []
    var filteredTeachers: [TeacherEntity] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSourceType {
        case .auditoriums:
            return filteredAuditoriums.count
        case .groups:
            return filteredGroups.count
        case .teachers:
            return filteredTeachers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsTableCell", for: indexPath)
        
        switch dataSourceType {
            
        case .auditoriums:
            let auditoriun = filteredAuditoriums[indexPath.row]
            cell.textLabel?.text = auditoriun.name
            
        case .groups:
            let group = filteredGroups[indexPath.row]
            cell.textLabel?.text = group.name
            
        case .teachers:
            let group = filteredTeachers[indexPath.row]
            cell.textLabel?.text = group.name
        }
        
        return cell
    }
}
