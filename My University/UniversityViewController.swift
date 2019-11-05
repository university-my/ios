//
//  UniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class UniversityViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    var universityID: Int64?
    private var dataSource: UniversityDataSource?
    
    private var auditoriumsDataSource: AuditoriumDataSource?
    private var groupsDataSource: GroupsDataSource?
    private var teachersDataSource: TeacherDataSource?
    
    // MARK: - Cells
    
    @IBOutlet weak var groupsCell: UITableViewCell!
    @IBOutlet weak var teachersCell: UITableViewCell!
    @IBOutlet weak var auditoriumsCell: UITableViewCell!
    @IBOutlet weak var favoritesCell: UITableViewCell!
    
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
    
    private func setup() {
        // Fetch university
        if let id = universityID {
            dataSource = UniversityDataSource()
            dataSource?.fetch(id: id)
            dataSource?.configureSections()
        }
        
        if let university = dataSource?.university {
            // Title
            title = university.shortName
            
            // Init all data sources
            auditoriumsDataSource = AuditoriumDataSource(universityID: university.id)
            groupsDataSource = GroupsDataSource(universityID: university.id)
            teachersDataSource = TeacherDataSource(universityID: university.id)
            
            // Favorites
            checkFavorites()
            
            // Start from groups,
            // And import auditoriums and teachers
            loadGroups()
        }
    }
    
    // MARK: - Favorites
    
    /// Check if need to show favorites after app launch
    private func checkFavorites() {
        guard let id = universityID else { return }
        let favoritesDataSource = FavoritesDataSource()
        favoritesDataSource.fetchUniversity(with: id)
        
        favoritesDataSource.fetchAuditoriums()
        favoritesDataSource.fetchGroups()
        favoritesDataSource.fetchTeachers()
        
        var showFavorites = false
        if favoritesDataSource.auditoriums?.fetchedObjects?.isEmpty == false {
            showFavorites = true
        } else if favoritesDataSource.groups?.fetchedObjects?.isEmpty == false {
            showFavorites = true
        } else if favoritesDataSource.teachers?.fetchedObjects?.isEmpty == false {
            showFavorites = true
        }
        if showFavorites {
            performSegue(withIdentifier: "favoritesWithoutAnimation", sender: nil)
        }
    }
    
    // MARK: - Table
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.sections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = dataSource?.sections[safe: indexPath.section]
        let row = section?.rows[safe: indexPath.row]
        
        if let kind = row?.kind {
            switch kind {
            case .auditoriums:
                performSegue(withIdentifier: "showAuditoriums", sender: nil)
            case .groups:
                performSegue(withIdentifier: "showGroups", sender: nil)
            case .teachers:
                performSegue(withIdentifier: "showTeachers", sender: nil)
            case .favorites:
                performSegue(withIdentifier: "showFavorites", sender: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = dataSource?.sections[safe: section]
        if let kind = section?.kind {
            switch kind {
            case .all:
                return dataSource?.university?.fullName
            case .favorites:
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showAuditoriums":
            let vc = segue.destination as? AuditoriumsTableViewController
            vc?.universityID = dataSource?.university?.id
            
        case "showGroups":
            let vc = segue.destination as? GroupsTableViewController
            vc?.universityID = dataSource?.university?.id
            
        case "showTeachers":
            let vc = segue.destination as? TeachersTableViewController
            vc?.universityID = dataSource?.university?.id
            
        case "showFavorites":
            let vc = segue.destination as? FavoritesViewController
            vc?.universityID = dataSource?.university?.id
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource?.sections[safe: section]
        return section?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataSource?.sections[safe: indexPath.section]
        let row = section?.rows[safe: indexPath.row]
        
        let kind = row!.kind
        switch kind {
            
        case .groups:
            return groupsCell
            
        case .teachers:
            return teachersCell
            
        case .auditoriums:
            return auditoriumsCell
            
        case .favorites:
            return favoritesCell
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
        guard let university = dataSource?.university else { return false }
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
}
