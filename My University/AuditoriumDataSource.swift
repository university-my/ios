//
//  AuditoriumDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 11/21/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class AuditoriumDataSource: NSObject {
    
    // MARK: - Init
    
    var university: UniversityEntity
    lazy var predicate = NSPredicate(format: "university == %@", university)
    
    init?(universityID id: Int64) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let context = appDelegate?.persistentContainer.viewContext else { return nil }
        
        if let university = UniversityEntity.fetch(id: id, context: context) {
            self.university = university
        } else {
            return nil
        }
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<AuditoriumEntity>? = {
        let request: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        request.predicate = predicate
        
        let firstSymbol = NSSortDescriptor(key: #keyPath(AuditoriumEntity.firstSymbol), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let name = NSSortDescriptor(key: #keyPath(AuditoriumEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [firstSymbol, name]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(AuditoriumEntity.firstSymbol), cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    func fetchAuditoriums() {
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
    
    private var importManager: Auditorium.Import?
    
    /// Import Auditoriums from backend
    func importAuditoriums(_ completion: @escaping ((_ error: Error?) -> ())) {
        guard let persistentContainer = persistentContainer else { return }
        
        importManager = Auditorium.Import(persistentContainer: persistentContainer, universityID: university.id)
        DispatchQueue.global().async { [weak self] in
            
            self?.importManager?.importAuditoriums({ (error) in
                
                DispatchQueue.main.async {
                    completion(error)
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource

extension AuditoriumDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "auditoriumCell", for: indexPath)
        
        // Configure cell
        if let auditorium = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = auditorium.name
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
