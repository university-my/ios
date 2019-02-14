//
//  TeacherDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class TeacherDataSource: NSObject {
  
  // MARK: - NSManagedObjectContext
  
  private lazy var viewContext: NSManagedObjectContext? = {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    return appDelegate?.persistentContainer.viewContext
  }()
  
  // MARK: - NSFetchedResultsController
  
  lazy var fetchedResultsController: NSFetchedResultsController<TeacherEntity>? = {
    let request: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
    
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
  
  func fetchTeachers() {
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
  
  // MARK: - Import Auditoriums
  
  private var teachersImportManager: Teacher.Import?
  
  /// Import Teachers from backend
  func importTeachers(_ completion: @escaping ((_ error: Error?) -> ())) {
    // Do nothing without CoreData.
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    guard let persistentContainer = appDelegate?.persistentContainer else { return }
    
    teachersImportManager = Teacher.Import(persistentContainer: persistentContainer)
    DispatchQueue.global().async { [weak self] in
      
      self?.teachersImportManager?.importTeachers({ (error) in
        
        DispatchQueue.main.async {
          completion(error)
        }
      })
    }
  }
}

// MARK: - UITableViewDataSource

extension TeacherDataSource: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController?.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = fetchedResultsController?.sections?[safe: section]
    return section?.numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell", for: indexPath)
    
    // Configure cell
    if let teacher = fetchedResultsController?.object(at: indexPath) {
      cell.textLabel?.text = teacher.name
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
