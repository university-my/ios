//
//  AuditoriumScheduleTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class AuditoriumScheduleTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()
    
    private var sectionsTitles: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // Refresh control.
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let auditorium = auditorium {
            // Title
            title = auditorium.name
            
            // Fetch old records first.
            performFetch()
            
            // TODO: Import records only if:
            // 1. Records not found
            // 2. Date of last record less than current date
            
            // Import records.
            importRecords()
        }
    }
    
    // MARK: - Import Records
    
    var auditorium: AuditoriumEntity?
    var auditoriumID: Int64?
    
    private var importForAuditorium: Record.ImportForAuditorium?
    
    private func importRecords() {
        // Do nothing without CoreData.
        guard let context = viewContext else { return }
        guard let auditorium = auditorium else { return }
        
        // Download records for Group from backend and save to database.
        importForAuditorium = Record.ImportForAuditorium(context: context, auditorium: auditorium)
        DispatchQueue.global().async {
            self.importForAuditorium?.importRecords({ (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    self.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    @objc func refreshContent() {
        importRecords()
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
            // Title
            var title = ""
            if let name = record.name {
                title = name
            }
            if let type = record.type {
                title += "\n" + type
            }
            cell.textLabel?.text = title
            
            // Detail
            if let pairName = record.pairName, let time = record.time {
                let detailed = pairName + " (\(time))"
                cell.detailTextLabel?.text = detailed
            } else if let time = record.time {
                cell.detailTextLabel?.text = "(\(time))"
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionsTitles.indices.contains(section) {
            return sectionsTitles[section]
        } else {
            return fetchedResultsController?.sections?[section].name
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            
            // TODO: Try use appearance
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .sectionBackgroundColor
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // TODO: Try use appearance
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    // MARK: - NSFetchedResultsController
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<RecordEntity>? = {
        guard let auditorium = auditorium else { return nil }
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "dateString", ascending: true),
            NSSortDescriptor(key: "time", ascending: true)
        ]
        request.predicate = NSPredicate(format: "auditorium == %@", auditorium)
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
            fetchedResultsController?.delegate = self
            try fetchedResultsController?.performFetch()
            
            // Generate title for sections
            if let controller = fetchedResultsController, let sections = controller.sections {
                var newSectionsTitles: [String] = []
                for section in sections {
                    if let firstObjectInSection = section.objects?.first as? RecordEntity {
                        if let date = firstObjectInSection.date {
                            let dateString = dateFormatter.string(from: date)
                            newSectionsTitles.append(dateString)
                        }
                    }
                }
                sectionsTitles = newSectionsTitles
            }
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension AuditoriumScheduleTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
