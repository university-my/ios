//
//  TeacherDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit
import os

class TeacherDataSource: NSObject {
    
    private let logger = Logger(subsystem: Bundle.identifier, category: "TeacherDataSource")
    
    // MARK: - Favorites
    
    private var favoritesImageView: UIImageView {
        UIImageView(image: UIImage.starFill)
    }
    
    // MARK: - Init
    
    var university: UniversityEntity
    
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
        persistentContainer?.viewContext
    }()
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<TeacherEntity>? = {
        let request: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        request.predicate = NSPredicate(format: "university == %@", university)
        
        let firstSymbol = NSSortDescriptor(key: #keyPath(TeacherEntity.firstSymbol), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let name = NSSortDescriptor(key: #keyPath(TeacherEntity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [firstSymbol, name]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(TeacherEntity.firstSymbol), cacheName: nil)
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
    
    private var syncController: Teacher.SyncController?
    
    /// Import Teachers from backend
    func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
        guard let container = persistentContainer else { return }
        
        syncController = Teacher.SyncController(persistentContainer: container, universityID: university.id)
        
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

extension TeacherDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath)
        
        // Configure cell
        if let teacher = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = teacher.name
            
            // Is favorites
            if teacher.isFavorite {
                cell.accessoryView = favoritesImageView
            } else {
                cell.accessoryView = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fetchedResultsController?.sections?[safe: section]?.name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        namesOfSections
    }
}
