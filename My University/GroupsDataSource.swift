//
//  GroupDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 11/21/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class GroupsDataSource: NSObject {
    
    // MARK: - Init
    
    private var university: UniversityEntity
    
    init(university: UniversityEntity) {
        self.university = university
    }
    
    // MARK: - NSManagedObjectContext
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer
    }()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        return persistentContainer?.viewContext
    }()
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<GroupEntity>? = {
        // Groups for university
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        let predicate = NSPredicate(format: "university == %@", university)
        request.predicate = predicate
        
        let firstSymbol = NSSortDescriptor(key: #keyPath(GroupEntity.firstSymbol), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let name = NSSortDescriptor(key: #keyPath(GroupEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [firstSymbol, name]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(GroupEntity.firstSymbol), cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
            collectNamesOfSections()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    // MARK: - Sections
    
    private var namesOfSections: [String] = []
    
    private func collectNamesOfSections() {
        var names: [String] = []
        if let sections = fetchedResultsController?.sections {
            for section in sections {
                names.append(section.name)
            }
        }
        namesOfSections = names
    }
    
    // MARK: - Import
    
    var importManager: Group.Import?
    
    /// Import Groups from backend
    func importGroups(_ completion: @escaping ((_ error: Error?) -> ())) {
        guard let persistentContainer = persistentContainer else { return }
        
        // Download Groups from backend and save to database.
        importManager = Group.Import(persistentContainer: persistentContainer, university: university)
        DispatchQueue.global().async { [weak self] in
            
            self?.importManager?.importGroups { (error) in
                
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension GroupsDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        
        // Configure cell
        if let group = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = group.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[safe: section]?.name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return namesOfSections
    }
}
