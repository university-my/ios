//
//  GroupScheduleTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class GroupScheduleTableViewController: UITableViewController {
    
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
        
        // Mark group as visited
        markGroupAsVisited()
        
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let group = group {
            // Name of the Group.
            title = group.name
            
            performFetch()
            
            setTitleForUpdateButton()
        }
    }
    
    // MARK: - UIBarButtonItem's
    
    private var updateButton: UIBarButtonItem?
    private var shareButton: UIBarButtonItem?
    
    @objc func update(_ sender: Any) {
        importRecords()
    }
    
    @objc func share(_ sender: Any) {
        guard let group = group else { return }
        var sharedItems: [Any] = []
        let url = "https://my-university.com.ua/universities/sumdu/groups/\(group.id)"
        if let siteURL = URL(string: url) {
            sharedItems = [siteURL]
        }
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func setTitleForUpdateButton() {
        if fetchedResultsController?.fetchedObjects?.isEmpty == true {
            updateButton?.title = NSLocalizedString("Download", comment: "Title for button on the Group screen")
        } else {
            updateButton?.title = NSLocalizedString("Update", comment: "Title for button on the Group screen")
        }
    }
    
    private func configureButtons() {
        activiyIndicatior?.removeFromSuperview()
        activiyIndicatior = nil
        
        updateButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(update(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(share(_:)))
        navigationItem.setRightBarButtonItems([shareButton!, updateButton!], animated: true)
    }
    
    // MARK: - Activity indicatior
    
    private var activiyIndicatior: UIActivityIndicatorView?
    
    private func showActiviyIndicatior() {
        navigationItem.rightBarButtonItems = []
        updateButton = nil
        shareButton = nil
        
        let activiyIndicatior = UIActivityIndicatorView(style: .white)
        activiyIndicatior.color = .orange
        activiyIndicatior.hidesWhenStopped = true
        activiyIndicatior.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activiyIndicatior)
        navigationItem.rightBarButtonItem?.tintColor = .orange
        self.activiyIndicatior = activiyIndicatior
    }
    
    // MARK: - Import Records
    
    var group: GroupEntity?
    var groupID: Int64?
    
    private var importForGroup: Record.ImportForGroup?
    
    private func importRecords() {
        // Do nothing without CoreData.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let persistentContainer = appDelegate?.persistentContainer else { return }
        
        guard let forGroup = group else { return }
        
        showActiviyIndicatior()
        
        // Download records for Group from backend and save to database.
        importForGroup = Record.ImportForGroup(persistentContainer: persistentContainer, group: forGroup)
        self.importForGroup?.importRecords({ (error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                self.performFetch()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.configureButtons()
                self.setTitleForUpdateButton()
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailTableCell", for: indexPath)
        
        // Configure the cell
        if let record = fetchedResultsController?.object(at: indexPath) {
            // Title
            cell.textLabel?.text = record.title
            
            // Detail
            cell.detailTextLabel?.text = record.detail
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionsTitles.indices.contains(section) {
            return sectionsTitles[section]
        } else {
            return fetchedResultsController?.sections?[safe: section]?.name
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .sectionBackgroundColor
            headerView.backgroundView = backgroundView
            headerView.textLabel?.textColor = UIColor.lightText
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = fetchedResultsController?.object(at: indexPath)
        performSegue(withIdentifier: "recordDetailed", sender: record)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "recordDetailed":
            if let destination = segue.destination as? RecordDetailedTableViewController {
                destination.record = sender as? RecordEntity
            }
            
        default:
            break
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<RecordEntity>? = {
        guard let group = group else { return nil }
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        let dateString = NSSortDescriptor(key: #keyPath(RecordEntity.dateString), ascending: true)
        let time = NSSortDescriptor(key: #keyPath(RecordEntity.time), ascending: true)
        
        request.sortDescriptors = [dateString, time]
        request.predicate = NSPredicate(format: "ANY groups == %@", group)
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.dateString), cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private func performFetch() {
        do {
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
    
    // MARK: - Is visited
    
    private func markGroupAsVisited() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext?.perform {
            if let group = self.group {
                group.isVisited = true
                appDelegate?.saveContext()
            }
        }
    }
}

// MARK: - UIStateRestoring

extension GroupScheduleTableViewController {
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let group = group {
            coder.encode(group.id, forKey: "groupID")
        }
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        groupID = coder.decodeInt64(forKey: "groupID")
        
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
        if let id = groupID, let context = viewContext {
            if let group = GroupEntity.fetch(id: id, context: context) {
                self.group = group
            }
        }
    }
}
