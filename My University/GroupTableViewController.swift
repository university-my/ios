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
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()
    
    private var sortBy: Filters {
        get {
            switch FilterData.process {
            case 1:
                return .week
            case 2:
                return .month
            default:
                return .day
            }
        }
        set {
            FilterData.process = newValue.rawValue
        }
    }
    
    private var sectionsTitles: [String] = []
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup Filters
        configureFilterButton(for: sortBy)
        
        setup()
    }
    
    func setup() {
        if let id = groupID, let context = viewContext {
            group = GroupEntity.fetch(id: id, context: context)
        }
        if let group = group {
            title = group.name
            performFetch()
            
            let records = fetchedResultsController?.fetchedObjects ?? []
            if records.isEmpty {
                importRecords()
            }
        }
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        showFilters()
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
    
    // MARK: - Prepare filters
    
    private func configureFilterButton(for state: Filters) {
        switch state {
        case .week, .month:
            filterButton.tintColor = UIColor.orange
            filterButton.image = UIImage(named: "AppliedFilters")
        default:
            filterButton.tintColor = UIColor.white
            filterButton.image = UIImage(named: "NoFilters")
        }
    }
    
    private func setDataForFilters(period: Filters) -> NSPredicate {
        var filterPredicate = NSPredicate()
        let dateFormatter = DateFormatter()
        switch sortBy {
        case .week:
            if let group = group, let startWeek = Date().startOfWeek, let endWeek = Date().endOfWeek {
                filterPredicate = NSPredicate(format: "ANY groups == %@ AND dateString >= %@ AND dateString <= %@", group, startWeek as NSDate, endWeek as NSDate)
            }
            return filterPredicate
        case .month:
            dateFormatter.dateFormat = "YYYY-MM"
            let currentMonth = dateFormatter.string(from: Date())
            if let group = group {
                filterPredicate = NSPredicate(format: "ANY groups == %@ AND dateString CONTAINS %@", group, currentMonth)
            }
            return filterPredicate
        default:
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            if let group = group {
                filterPredicate = NSPredicate(format: "ANY groups == %@ AND dateString CONTAINS %@", group, currentDate)
            }
            return filterPredicate
        }
    }
    
    private func showFilters() {
        let alert = UIAlertController(title: NSLocalizedString("Filter", comment: ""), message: NSLocalizedString("Show schedule for:", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Month", comment: ""), style: .default, handler: { (_) in
            self.sortBy = .month
            let filterPredicate = self.setDataForFilters(period: self.sortBy)
            self.configureFilterButton(for: self.sortBy)
            self.fetchedResultsController?.fetchRequest.predicate = filterPredicate
            do {
                try self.fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.importRecords()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Week", comment: ""), style: .default, handler: { (_) in
            self.sortBy = .week
            let filterPredicate = self.setDataForFilters(period: self.sortBy)
            self.configureFilterButton(for: self.sortBy)
            self.fetchedResultsController?.fetchRequest.predicate = filterPredicate
            do {
                try self.fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.importRecords()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Day",comment: ""), style: .default, handler: { (_) in
            self.sortBy = .day
            let filterPredicate = self.setDataForFilters(period: self.sortBy)
            self.configureFilterButton(for: self.sortBy)
            self.fetchedResultsController?.fetchRequest.predicate = filterPredicate
            do {
                try self.fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.importRecords()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
                self.performFetch()
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
        
        let predicate = setDataForFilters(period: sortBy)
        
        request.sortDescriptors = [dateString, time]
        request.predicate = predicate
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
