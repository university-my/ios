//
//  DetailTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class DetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var group: GroupEntity?
    
    private let queue = OperationQueue()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Name of the Group.
        title = group?.name
        
        // Import records
        importRecords()
    }
    
    // MARK: - Import Records
    
    private var recordsImportManager: RecordsImportManager?
    
    private func importRecords() {
        // Do nothing without CoreData.
        guard let context = viewContext else { return }
        guard let forGroup = group else { return }
        
        // Download records for Group from backend and save to database.
        recordsImportManager = RecordsImportManager(context: context, group: forGroup)
        DispatchQueue.global().async {
            self.recordsImportManager?.importRecords({ (error) in
                
                // TODO: Show error
                
                DispatchQueue.main.async {
                    self.performFetch()
                    self.tableView.reloadData()
                }
            })
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTableCell", for: indexPath)
        
        // Configure the cell
        if let record = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = record.pairName + " " + (record.type ?? "")
            cell.detailTextLabel?.text = record.time + " " + (record.reason ?? "")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<RecordEntity>? = {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "dateString", ascending: true),
            NSSortDescriptor(key: "time", ascending: true)
        ]
        if let group = group {
            request.predicate = NSPredicate(format: "group == %@", group)
        }
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "dateString", cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}
