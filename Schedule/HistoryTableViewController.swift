//
//  HistoryTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 08.01.18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class HistoryTableViewController: UITableViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Fetch from database
        performFetch()
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableCell", for: indexPath)

        // Configure cell
        if let group = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = group.name
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showRecords", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        cell.selectedBackgroundView = bgColorView
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecords", let detailTableViewController = segue.destination as? DetailTableViewController {
            if tableView == self.tableView, let indexPath = tableView.indexPathForSelectedRow {
                let selectedGroup = fetchedResultsController?.object(at: indexPath)
                detailTableViewController.group = selectedGroup
            }
        }
    }

    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<GroupEntity>? = {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "firstSymbol", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        ]
        request.fetchBatchSize = 20
        
        request.predicate = NSPredicate(format: "records.@count > 0")
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "firstSymbol", cacheName: nil)
            controller.delegate = self
            return controller
        } else {
            return nil
        }
    }()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
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

// MARK: - NSFetchedResultsControllerDelegate

extension HistoryTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
