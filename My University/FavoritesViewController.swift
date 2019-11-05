//
//  FavoritesViewController.swift
//  My University
//
//  Created by Yura Voevodin on 6/1/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class FavoritesViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    var university: UniversityEntity?
    var dataSource: FavoritesDataSource? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource?.fetchAuditoriums()
        dataSource?.fetchGroups()
        dataSource?.fetchTeachers()
        dataSource?.configureSections()
        tableView.reloadData()
        
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func setup() {
        universityID = University.selectedUniversityID
        if let id = universityID {
            dataSource = FavoritesDataSource()
            dataSource?.fetchUniversity(with: id)
        }
    }
    
    // MARK: - Table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.sections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableSection = dataSource?.sections[safe: section]
        if let kind = tableSection?.kind {
            switch kind {
            case .auditoriums:
                return dataSource?.auditoriums?.fetchedObjects?.count ?? 0
            case .groups:
                return dataSource?.groups?.fetchedObjects?.count ?? 0
            case .teachers:
                return dataSource?.teachers?.fetchedObjects?.count ?? 0
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath)
        
        let section = dataSource?.sections[safe: indexPath.section]
        if let kind = section?.kind {
            switch kind {
            case .auditoriums:
                let auditorium = dataSource?.auditoriums?.fetchedObjects?[safe: indexPath.row]
                cell.textLabel?.text = auditorium?.name
            case .groups:
                let group = dataSource?.groups?.fetchedObjects?[safe: indexPath.row]
                cell.textLabel?.text = group?.name
            case .teachers:
                let teacher = dataSource?.teachers?.fetchedObjects?[safe: indexPath.row]
                cell.textLabel?.text = teacher?.name
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableSection = dataSource?.sections[safe: section]
        return tableSection?.name
    }
    
    // MARK: - Table delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = dataSource?.sections[safe: indexPath.section]
        if let kind = section?.kind {
            switch kind {
            case .auditoriums:
                performSegue(withIdentifier: "showAuditorium", sender: nil)
            case .groups:
                performSegue(withIdentifier: "showGroup", sender: nil)
            case .teachers:
                performSegue(withIdentifier: "showTeacher", sender: nil)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showAuditorium":
            let vc = segue.destination as? AuditoriumTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let auditorium = dataSource?.auditoriums?.fetchedObjects?[safe: indexPath.row]
                vc?.auditoriumID = auditorium?.id
            }
            
        case "showGroup":
            let vc = segue.destination as? GroupTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let group = dataSource?.groups?.fetchedObjects?[safe: indexPath.row]
                vc?.groupID = group?.id
            }
            
        case "showTeacher":
            let vc = segue.destination as? TeacherTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let teacher = dataSource?.teachers?.fetchedObjects?[safe: indexPath.row]
                vc?.teacherID = teacher?.id
            }
            
        default:
            break
        }
    }
}
