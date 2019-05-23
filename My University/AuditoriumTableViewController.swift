//
//  AuditoriumTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class AuditoriumTableViewController: GenericTableViewController {
    
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
        if let id = auditoriumID, let context = viewContext {
            auditorium = AuditoriumEntity.fetch(id: id, context: context)
        }
        
        if let auditorium = auditorium {
            title = auditorium.name
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
        guard let auditorium = auditorium else { return }
        guard let universityURL = auditorium.university?.url else { return }
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/auditoriums/\(auditorium.id)"
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
            if let auditorium = auditorium, let startWeek = Date().startOfWeek, let endWeek = Date().endOfWeek {
                filterPredicate = NSPredicate(format: "auditorium == %@ AND dateString >= %@ AND dateString <= %@", auditorium, startWeek as NSDate, endWeek as NSDate)
            }
            return filterPredicate
        case .month:
            dateFormatter.dateFormat = "YYYY-MM"
            let currentMonth = dateFormatter.string(from: Date())
            if let auditorium = auditorium {
                filterPredicate = NSPredicate(format: "auditorium == %@ AND dateString CONTAINS %@", auditorium, currentMonth)
            }
            return filterPredicate
        default:
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            if let auditorium = auditorium {
                filterPredicate = NSPredicate(format: "auditorium == %@ AND dateString CONTAINS %@", auditorium, currentDate)
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
    
    var auditoriumID: Int64?
    private var auditorium: AuditoriumEntity?
    
    private var importManager: Record.ImportForAuditorium?
    
    private func importRecords() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let persistentContainer = appDelegate?.persistentContainer else { return }
        
        guard let auditoriumID = auditorium?.id else { return }
        guard let university = auditorium?.university else { return }
        guard let universityURL = university.url else { return }
        
        let text = NSLocalizedString("Loading records ...", comment: "")
        showNotification(text: text)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Download records for Auditorium from backend and save to database.
        importManager = Record.ImportForAuditorium(persistentContainer: persistentContainer, auditoriumID: auditoriumID, universityURL: universityURL)
        DispatchQueue.global().async {
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
        guard let auditorium = auditorium else { return nil }
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

extension AuditoriumTableViewController {

  override func encodeRestorableState(with coder: NSCoder) {
    if let id = auditoriumID {
      coder.encode(id, forKey: "auditoriumID")
    }
    super.encodeRestorableState(with: coder)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    auditoriumID = coder.decodeInt64(forKey: "auditoriumID")
  }
    
    override func applicationFinishedRestoringState() {
        setup()
    }
}
