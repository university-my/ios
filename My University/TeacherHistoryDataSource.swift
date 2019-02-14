//
//  TeacherHistoryDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class TeacherHistoryDataSource: NSObject {
    
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
        
        request.predicate = NSPredicate(format: "\(#keyPath(TeacherEntity.isVisited)) == YES")
        
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
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}

// MARK: - Table view data source

extension TeacherHistoryDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableCell", for: indexPath)
        
        // Configure cell
        if let teacher = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = teacher.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[safe: section]?.name
    }
}
