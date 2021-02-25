//
//  SearchResultsTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 16.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

enum DataSourceType: Int {
    case groups = 0, classrooms, teachers
}

class SearchResultsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var dataSourceType: DataSourceType = .classrooms
    
    var filteredGroups: [GroupEntity] = []
    var filteredClassrooms: [ClassroomEntity] = []
    var filteredTeachers: [TeacherEntity] = []
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSourceType {
        case .classrooms:
            return filteredClassrooms.count
        case .groups:
            return filteredGroups.count
        case .teachers:
            return filteredTeachers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsTableCell", for: indexPath)
        
        switch dataSourceType {
            
        case .classrooms:
            let classroom = filteredClassrooms[indexPath.row]
            cell.textLabel?.text = classroom.name
            
        case .groups:
            let group = filteredGroups[indexPath.row]
            cell.textLabel?.text = group.name
            
        case .teachers:
            let teacher = filteredTeachers[indexPath.row]
            cell.textLabel?.text = teacher.name
        }
        
        return cell
    }
}
