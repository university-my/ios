//
//  MainTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.06.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class MainTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private lazy var fetchedResultsController: NSFetchedResultsController<GroupEntity>? = {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "firstSymbol", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "firstSymbol", cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    let queue = OperationQueue()
    
    // MARK: - Lifecycle
    
    // TODO: Handle errors from Operations
    // TODO: Check without Interner connection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        guard let context = viewContext else { return }
        
        performFetch()
        let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
        if  fetchedObjects.isEmpty {
            
            if let getGroups = GetGroupsOperation(context: context, completionHandler: {
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }) {
                queue.addOperation(getGroups)
            }
        } else {
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        return section?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if let group = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = group.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
}

// MARK: - Helpers

extension MainTableViewController {
    
    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
    
    private func updateUI() {
        performFetch()
        tableView.reloadData()
    }
}
