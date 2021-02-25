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

private let classroomsCell = "classroomsCell"
private let groupsCell = "groupsCell"
private let teachersCell = "teachersCell"
private let favoritesCell = "favoritesCell"

class UniversityViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    private let logic: UniversityLogicController
    
    var universityID: Int64?
    private var dataSource: UniversityDataSource!
    
    private var classroomsDataSource: ClassroomDataSource?
    private var groupsDataSource: GroupsDataSource?
    private var teachersDataSource: TeacherDataSource?
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = UniversityLogicController()
        
        super.init(coder: coder)
    }
    
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
        presentWhatsNewIfNeeded()
    }
    
    private func setup() {
        configurePreferencesMenu()
        
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
            classroomsDataSource = ClassroomDataSource(universityID: university.id)
            groupsDataSource = GroupsDataSource(universityID: university.id)
            teachersDataSource = TeacherDataSource(universityID: university.id)
            
            // Start from groups,
            // And import classrooms and teachers
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
            
        case .classrooms:
            if let classroom = dataSource.classrooms?.fetchedObjects?[safe: indexPath.row] {
                selectedEntityID = classroom.id
                performSegue(withIdentifier: .classroomDetails)
            }
            
        case .groups:
            if let group = dataSource.groups?.fetchedObjects?[safe: indexPath.row] {
                selectedEntityID = group.id
                performSegue(withIdentifier: .groupDetails)
            }
            
        case .teachers:
            if let teacher = dataSource.teachers?.fetchedObjects?[safe: indexPath.row] {
                selectedEntityID = teacher.id
                performSegue(withIdentifier: .teacherDetails)
            }
            
        case .university:
            let row = dataSource.universityRows[indexPath.row]
            if case .classrooms = row.kind {
                performSegue(withIdentifier: .showClassrooms)
            } else if case .groups = row.kind {
                performSegue(withIdentifier: .showGroups)
            } else if case .teachers = row.kind {
                performSegue(withIdentifier: .showTeachers)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeader(in: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource.titleForFooter(in: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = dataSource.sections[safe: section] else {
            return 0
        }
        switch section.kind {
        case .classrooms:
            return dataSource.classrooms?.fetchedObjects?.count ?? 0
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
            
        case .classrooms:
            let classroom = dataSource?.classrooms?.fetchedObjects?[safe: indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCell, for: indexPath)
            cell.textLabel?.text = classroom?.name
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
            
            if case .classrooms = row.kind {
                let cell = tableView.dequeueReusableCell(withIdentifier: classroomsCell, for: indexPath)
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case .classroomDetails:
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? ClassroomViewController
            vc?.entityID = selectedEntityID
            
        case .groupDetails:
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? GroupViewController
            vc?.entityID = selectedEntityID
            
        case .teacherDetails:
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? TeacherViewController
            vc?.entityID = selectedEntityID
            
        case .showClassrooms:
            let vc = segue.destination as? ClassroomsTableViewController
            vc?.universityID = dataSource.university?.id
            
        case .showGroups:
            let vc = segue.destination as? GroupsTableViewController
            vc?.universityID = dataSource.university?.id
            
        case .showTeachers:
            let vc = segue.destination as? TeachersTableViewController
            vc?.universityID = dataSource.university?.id
            
        default:
            break
        }
    }
    
    // MARK: - Show
    
    var selectedEntityID: Int64?
    
    func show(_ entity: Entity) {
        selectedEntityID = entity.id
        
        switch entity.kind {
        case .classroom:
            performSegue(withIdentifier: .classroomDetails)
        case .group:
            performSegue(withIdentifier: .groupDetails)
        case .teacher:
            performSegue(withIdentifier: .teacherDetails)
        }
    }
    
    // MARK: - Groups
    
    var shouldImportGroups: Bool {
        dataSource.university?.showGroups ?? false
    }
    
    private func loadGroups() {
        guard shouldImportGroups else {
            loadTeachers()
            return
        }
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
    
    var shouldImportTeachers: Bool {
        dataSource.university?.showTeachers ?? false
    }
    
    private func loadTeachers() {
        guard shouldImportTeachers else {
            loadClassrooms()
            return
        }
        guard let dataSource = teachersDataSource else { return }
        dataSource.performFetch()
        
        let teachers = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if teachers.isEmpty {
            
            dataSource.importTeachers { (error) in
                
                if let _ = error {
                    
                } else {
                    self.loadClassrooms()
                }
            }
        } else {
            loadClassrooms()
        }
    }
    
    // MARK: - Classrooms
    
    var shouldImportClassrooms: Bool {
        dataSource.university?.showClassrooms ?? false
    }
    
    private func loadClassrooms() {
        guard shouldImportClassrooms else {
            return
        }
        guard let dataSource = classroomsDataSource else { return }
        dataSource.performFetch()
        
        let classrooms = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if classrooms.isEmpty {
            
            dataSource.importClassrooms { (error) in
                
                if let _ = error {
                    
                }
            }
        }
    }

    // MARK: - What's new
    
    private func presentWhatsNewIfNeeded() {
        if logic.needToPresentWhatsNew() {
            // What's new
            var whatsNewView = WhatsNewView()
            
            // Continue
            whatsNewView.continueAction = {
                self.dismiss(animated: true)
            }
            
            let hostingController = UIHostingController(rootView: whatsNewView)
            present(hostingController, animated: true)
            
            // Present only once
            logic.updateLastVersionForNewFeatures()
        }
    }
    
    // MARK: - Preferences
    
    @IBOutlet weak var preferencesBarButtonItem: UIBarButtonItem!
    
    private func configurePreferencesMenu() {
        let changeUniversity = UIAction(
            title: NSLocalizedString("Change University", comment: "Action title"),
            image: UIImage(systemName: "list.dash")
        ) { _ in
            University.selectedUniversityID = nil
            Entity.Manager.shared.deleteLastOpened()
            self.performSegue(withIdentifier: .changeUniversity)
        }
        
        let reportProblem = UIAction(
            title: NSLocalizedString("Report a problem", comment: "Action title"),
            image: UIImage(systemName: "exclamationmark.bubble.fill")
        ) { _ in
            UIApplication.shared.open(.contacts)
        }
        
        preferencesBarButtonItem.menu = UIMenu(title: "", children: [changeUniversity, reportProblem])
    }
}

// MARK: - SegueIdentifier

private extension UniversityViewController.SegueIdentifier {
    static let classroomDetails = "classroomDetails"
    static let changeUniversity = "changeUniversity"
    static let groupDetails = "groupDetails"
    static let showClassrooms = "showClassrooms"
    static let showGroups = "showGroups"
    static let showTeachers = "showTeachers"
    static let teacherDetails = "teacherDetails"
}

// MARK: - NSFetchedResultsControllerDelegate

extension UniversityViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Re-configure sections
        dataSource.configureSections()
        tableView.reloadData()
    }
}
