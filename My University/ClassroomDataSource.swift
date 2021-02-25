//
//  ClassroomDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 11/21/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit
import os

class ClassroomDataSource: NSObject {
    
    private let logger = Logger(subsystem: Bundle.identifier, category: "ClassroomDataSource")
    
    // MARK: - Favorites
    
    private var favoritesImageView: UIImageView {
        UIImageView(image: UIImage.starFill)
    }
    
    // MARK: - Init
    
    private var university: UniversityEntity
    
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
    
    lazy var viewContext: NSManagedObjectContext? = {
        return persistentContainer?.viewContext
    }()
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<ClassroomEntity>? = {
        let request: NSFetchRequest<ClassroomEntity> = ClassroomEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        
        let firstSymbol = NSSortDescriptor(key: #keyPath(ClassroomEntity.firstSymbol), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let name = NSSortDescriptor(key: #keyPath(ClassroomEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [firstSymbol, name]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(ClassroomEntity.firstSymbol), cacheName: nil)
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
            logger.error("Error in the fetched results controller: \(error.localizedDescription).")
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
    
    private var syncController: Classroom.SyncController?
    
    /// Import Classrooms from backend
    func importClassrooms(_ completion: @escaping ((_ error: Error?) -> ())) {
        guard let container = persistentContainer else { return }
        
        syncController = Classroom.SyncController(persistentContainer: container, universityID: university.id)
        
        DispatchQueue.global().async { [weak self] in
            
            self?.syncController?.beginSync({ (result) in
                
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self?.logger.error("\(error.localizedDescription)")
                        completion(error)
                    case .success:
                        completion(nil)
                    }
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource

extension ClassroomDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classroomCell", for: indexPath)
        
        // Configure cell
        if let classroom = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = classroom.name
            
            // Is favorites
            if classroom.isFavorite {
                cell.accessoryView = favoritesImageView
            } else {
                cell.accessoryView = nil
            }
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
