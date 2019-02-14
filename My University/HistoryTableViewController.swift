//
//  HistoryTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 08.01.18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class HistoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private lazy var auditoriumDataSource: AuditoriumHistoryDataSource = {
        return AuditoriumHistoryDataSource()
    }()
    
    private lazy var groupDataSource: GroupHistoryDataSource = {
        return GroupHistoryDataSource()
    }()
    
    private lazy var teacherDataSource: TeacherHistoryDataSource = {
        return TeacherHistoryDataSource()
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Loading...
        loadCurrentDataSource()
    }
    
    // MARK: - Auditoriums
    
    private func fetchAuditoriums()  {
        tableView.dataSource = auditoriumDataSource
        auditoriumDataSource.performFetch()
        tableView.reloadData()
    }
    
    // MARK: - Groups
    
    private func fetchGroups()  {
        tableView.dataSource = groupDataSource
        groupDataSource.performFetch()
        tableView.reloadData()
    }
    
    // MARK: - Teachers
    
    private func fetchTeachers()  {
        tableView.dataSource = teacherDataSource
        teacherDataSource.performFetch()
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSourceType {
        case .auditoriums:
            performSegue(withIdentifier: "showAuditoriumRecords", sender: nil)
        case .groups:
            performSegue(withIdentifier: "showGroupRecords", sender: nil)
        case .teachers:
            performSegue(withIdentifier: "showTeacherRecords", sender: nil)
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
        
        switch segue.identifier {
            
        case "showAuditoriumRecords":
            if let detailTableViewController = segue.destination as? AuditoriumScheduleTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedAuditorium = auditoriumDataSource.fetchedResultsController?.object(at: indexPath)
                    detailTableViewController.auditorium = selectedAuditorium
                }
            }
            
        case "showGroupRecords":
            if let detailTableViewController = segue.destination as? GroupScheduleTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedGroup = groupDataSource.fetchedResultsController?.object(at: indexPath)
                    detailTableViewController.group = selectedGroup
                }
            }
            
        case "showTeacherRecords":
            if let detailTableViewController = segue.destination as? TeacherScheduleTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedTeacher = teacherDataSource.fetchedResultsController?.object(at: indexPath)
                    detailTableViewController.teacher = selectedTeacher
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
    
    @IBAction func typeChanged(_ sender: Any) {
        loadCurrentDataSource()
    }
    
    private func loadCurrentDataSource() {
        switch dataSourceType {
        case .auditoriums:
            fetchAuditoriums()
        case .groups:
            fetchGroups()
        case .teachers:
            fetchTeachers()
        }
    }
}
