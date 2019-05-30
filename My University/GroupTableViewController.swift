//
//  GroupTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class GroupTableViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup Filters
        barButtonItem = filterButton
        configurePeriodButton()
        
        setup()
        
        setupFavoriteButton(favoriteButton, favorite: isFavorite)
    }
    
    func setup() {
        if let id = groupID, let context = viewContext {
            group = GroupEntity.fetch(id: id, context: context)
            isFavorite = GroupEntity.isFavorite(id: id, context: context)
        }
        if let group = group {
            title = group.name
            performFetch(fetchedResultsController: fetchedResultsController)
            
            let records = fetchedResultsController?.fetchedObjects ?? []
            if records.isEmpty {
                importRecords()
            }
        }
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        if let group = group {
            fetchDataForPeriod(entity: group, fetchedResultsController: fetchedResultsController)
        }
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        importRecords()
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let group = group else { return }
        guard let universityURL = group.university?.url else { return }
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/groups/\(group.id)"
        if let siteURL = URL(string: url) {
            let sharedItems = [siteURL]
            let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    // MARK: - Favorites
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if isFavorite {
            isFavorite = false
        } else {
            isFavorite = true
        }
        if let group = group, let context = viewContext {
            markAsFavorite(for: group, mark: isFavorite, viewContext: context)
        }
        setupFavoriteButton(favoriteButton, favorite: isFavorite)
    }
    
    // MARK: - Import Records
    
    private var group: GroupEntity?
    var groupID: Int64?
    
    private var importManager: Record.ImportForGroup?
    
    private func importRecords() {
        // Do nothing without CoreData.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let persistentContainer = appDelegate?.persistentContainer else { return }
        
        guard let group = group else { return }
        guard let university = group.university else { return }
        
        let text = NSLocalizedString("Loading records ...", comment: "")
        showNotification(text: text)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Download records for Group from backend and save to database.
        importManager = Record.ImportForGroup(persistentContainer: persistentContainer, group: group, university: university)
        self.importManager?.importRecords({ (error) in
            
            DispatchQueue.main.async {

                UIApplication.shared.isNetworkActivityIndicatorVisible = false

                if let error = error {
                    self.showNotification(text: error.localizedDescription)
                } else {
                    self.hideNotification()
                }
                self.performFetch(fetchedResultsController: self.fetchedResultsController)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
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
                destination.recordID = (sender as? RecordEntity)?.id
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
        request.predicate = predicate(for: currentPeriod, entity: group)
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.dateString), cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
}

// MARK: - UIStateRestoring

extension GroupTableViewController {
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let id = groupID {
            coder.encode(id, forKey: "groupID")
        }
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        groupID = coder.decodeInt64(forKey: "groupID")
    }
    
    override func applicationFinishedRestoringState() {
        setup()
    }
}
