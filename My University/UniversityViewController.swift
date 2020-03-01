//
//  UniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit
import SwiftUI

// MARK: - Cells

private let auditoriumsCell = "auditoriumsCell"
private let groupsCell = "groupsCell"
private let teachersCell = "teachersCell"
private let favoritesCell = "favoritesCell"

class UniversityViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    private var dataSource: UniversityDataSource!
    
    private var auditoriumsDataSource: AuditoriumDataSource?
    private var groupsDataSource: GroupsDataSource?
    private var teachersDataSource: TeacherDataSource?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Current university is selected one
        universityID = University.selectedUniversityID
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide toolbar
        navigationController?.setToolbarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // What's new
        checkWhatsNew()
    }
    
    private func setup() {
        // Fetch university
        if let id = universityID {
            dataSource = UniversityDataSource()
            dataSource.fetch(id: id)
            dataSource.fetchFavorites(delegate: self)
            dataSource.configureSections()
        }
        
        if let university = dataSource.university {
            // Title
            title = university.shortName
            
            // Init all data sources
            auditoriumsDataSource = AuditoriumDataSource(universityID: university.id)
            groupsDataSource = GroupsDataSource(universityID: university.id)
            teachersDataSource = TeacherDataSource(universityID: university.id)
            
            // Start from groups,
            // And import auditoriums and teachers
            loadGroups()
        }
    }
    
    // MARK: - Table
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = dataSource.sections[safe: indexPath.section] else { return }
        
        switch section.kind {
        case .auditoriums:
            performSegue(withIdentifier: "showAuditorium", sender: nil)
        case .groups:
            performSegue(withIdentifier: "showGroup", sender: nil)
        case .teachers:
            performSegue(withIdentifier: "showTeacher", sender: nil)
            
        case .university:
            let row = dataSource.universityRows[indexPath.row]
            if case .auditoriums = row.kind {
                performSegue(withIdentifier: "showAuditoriums", sender: nil)
            } else if case .groups = row.kind {
                performSegue(withIdentifier: "showGroups", sender: nil)
            } else if case .teachers = row.kind {
                performSegue(withIdentifier: "showTeachers", sender: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeader(in: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource.titleForFooter(in: section)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showAuditoriums":
            let vc = segue.destination as? AuditoriumsTableViewController
            vc?.universityID = dataSource.university?.id
            
        case "showGroups":
            let vc = segue.destination as? GroupsTableViewController
            vc?.universityID = dataSource.university?.id
            
        case "showTeachers":
            let vc = segue.destination as? TeachersTableViewController
            vc?.universityID = dataSource.university?.id
            
        case "showAuditorium":
            let vc = segue.destination as? AuditoriumTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let auditorium = dataSource.auditoriums?.fetchedObjects?[safe: indexPath.row]
                vc?.auditoriumID = auditorium?.id
            }
            
        case "showGroup":
            let vc = segue.destination as? GroupTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let group = dataSource.groups?.fetchedObjects?[safe: indexPath.row]
                vc?.groupID = group?.id
            }
            
        case "showTeacher":
            let vc = segue.destination as? TeacherTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let teacher = dataSource.teachers?.fetchedObjects?[safe: indexPath.row]
                vc?.teacherID = teacher?.id
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = dataSource.sections[safe: section] else {
            return 0
        }
        switch section.kind {
        case .auditoriums:
            return dataSource.auditoriums?.fetchedObjects?.count ?? 0
        case .groups:
            return dataSource.groups?.fetchedObjects?.count ?? 0
        case .teachers:
            return dataSource.teachers?.fetchedObjects?.count ?? 0
        case .university:
            return dataSource.universityRows.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataSource.sections[indexPath.section]
        
        switch section.kind {
            
        case .auditoriums:
            let auditorium = dataSource?.auditoriums?.fetchedObjects?[safe: indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCell, for: indexPath)
            cell.textLabel?.text = auditorium?.name
            return cell
            
        case .groups:
            let group = dataSource?.groups?.fetchedObjects?[safe: indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCell, for: indexPath)
            cell.textLabel?.text = group?.name
            return cell
            
        case .teachers:
            let teacher = dataSource?.teachers?.fetchedObjects?[safe: indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCell, for: indexPath)
            cell.textLabel?.text = teacher?.name
            return cell
            
        case .university:
            let row = dataSource.universityRows[indexPath.row]
            
            if case .auditoriums = row.kind {
                let cell = tableView.dequeueReusableCell(withIdentifier: auditoriumsCell, for: indexPath)
                return cell
                
            } else if case .groups = row.kind {
                let cell = tableView.dequeueReusableCell(withIdentifier: groupsCell, for: indexPath)
                return cell
                
            } else if case .teachers = row.kind {
                let cell = tableView.dequeueReusableCell(withIdentifier: teachersCell, for: indexPath)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCell, for: indexPath)
                cell.textLabel?.text = nil
                return cell
            }
        }
    }
    
    // MARK: - Groups
    
    private func loadGroups() {
        guard let dataSource = groupsDataSource else { return }
        dataSource.performFetch()
        let groups = dataSource.fetchedResultsController?.fetchedObjects ?? []
        
        if groups.isEmpty {
            
            dataSource.importGroups { (error) in
                
                if let _ = error {
                    
                } else {
                    self.loadTeachers()
                }
            }
        } else {
            loadTeachers()
        }
    }
    
    // MARK: - Teachers
    
    private func loadTeachers() {
        guard let dataSource = teachersDataSource else { return }
        dataSource.performFetch()
        
        let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            
            dataSource.importTeachers { (error) in
                
                if let _ = error {
                    
                } else {
                    if self.shouldImportAuditoriums() {
                        self.loadAuditoriums()
                    }
                }
            }
        } else {
            if shouldImportAuditoriums() {
                loadAuditoriums()
            }
        }
    }
    
    // MARK: - Auditoriums
    
    private func shouldImportAuditoriums() -> Bool {
        guard let university = dataSource.university else { return false }
        if university.isKPI {
            return false
        } else {
            return true
        }
    }
    
    private func loadAuditoriums() {
        guard let dataSource = auditoriumsDataSource else { return }
        dataSource.performFetch()
        
        let auditoriums = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if auditoriums.isEmpty {
            
            dataSource.importAuditoriums { (error) in
                
                if let _ = error {
                    
                }
            }
        }
    }

    // MARK: - What's new

    private func checkWhatsNew() {
        if UserData.whatsNew1_6_3 {
            // What's new in version 1.6.3
            let swiftUIView = WhatsNewOneSixThree {
                self.dismiss(animated: true)
            }
            let hostingController = UIHostingController(rootView: swiftUIView)
            present(hostingController, animated: true)

            // Present only once
            UserData.whatsNew1_6_3 = false
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension UniversityViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Re-configure sections
        dataSource.configureSections()
        tableView.reloadData()
    }
}
