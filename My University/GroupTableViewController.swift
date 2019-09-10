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

    private var sectionsTitles: [String] = []

    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        setup()
    }
    
    func setup() {
        updateDateButton()

        if let id = groupID, let context = viewContext {
            group = GroupEntity.fetch(id: id, context: context)
        }
        if let group = group {
            title = group.name

            // Is Favorites
            favoriteButton.markAs(isFavorites: group.isFavorite)

            // Records
            performFetch()

            let records = fetchedResultsController?.fetchedObjects ?? []
            if records.isEmpty {
              // Show activity indicator
              showActivity()
            }

            // Start import
            importRecords()
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
        guard let slug = group.slug else { return }
      let dateString = DateFormatter.short.string(from: DatePicker.shared.pairDate)
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/groups/\(slug)?pair_date=\(dateString)"
        if let siteURL = URL(string: url) {
            let sharedItems = [siteURL]
            let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    // MARK: - Favorites
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if let group = group {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            group.isFavorite.toggle()
            appDelegate?.saveContext()
            favoriteButton.markAs(isFavorites: group.isFavorite)
        }
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

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Download records for Group from backend and save to database.
        let selectedDate = DatePicker.shared.pairDate
        importManager = Record.ImportForGroup(persistentContainer: persistentContainer, group: group, university: university)
        importManager?.importRecords(for: selectedDate, { (error) in
            
            DispatchQueue.main.async {

                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.processResultOfImport(error: error)
            }
        })
    }
    
    private func processResultOfImport(error: Error?) {
        if let error = error {
            show(message: error.localizedDescription)
        } else {
            hideActivity()
        }
        performFetch()
        refreshControl?.endRefreshing()
        let records = fetchedResultsController?.fetchedObjects ?? []
        if records.isEmpty {
            show(message: noRecordsMessage)
        } else {
            hideMessage()
            tableView.reloadData()
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
                destination.groupID = groupID
                destination.teacherID = nil
                destination.auditoriumID = nil
            }
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? DatePickerViewController
            vc?.selectDate = {
                self.updateDateButton()
                self.fetchOrImportRecordsForSelectedDate()
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
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        let dateString = NSSortDescriptor(key: #keyPath(RecordEntity.dateString), ascending: true)
        let time = NSSortDescriptor(key: #keyPath(RecordEntity.time), ascending: true)

        request.sortDescriptors = [dateString, time]
        request.predicate = generatePredicate()
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
                            let dateString = DateFormatter.full.string(from: date)
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
    
    private func generatePredicate() -> NSPredicate? {
        guard let group = group else { return nil }

        let selectedDate = DatePicker.shared.pairDate
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let groupsPredicate = NSPredicate(format: "ANY groups == %@", group)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupsPredicate, datePredicate])
        return compoundPredicate
    }

  // MARK: - Date

  @IBOutlet weak var dateButton: UIBarButtonItem!

  private func updateDateButton() {
    let selectedDate = DatePicker.shared.pairDate
    dateButton.title = DateFormatter.full.string(from: selectedDate)
  }
    
    private func fetchOrImportRecordsForSelectedDate() {
        fetchedResultsController?.fetchRequest.predicate = generatePredicate()
        
        performFetch()
        
        let records = fetchedResultsController?.fetchedObjects ?? []
        if records.isEmpty {
            
            // Hide previous records or activity
            hideActivity()
            tableView.reloadData()
            
            // Show activity indicator
            showActivity()
            
            // Start import
            importRecords()
        } else {
            hideActivity()
            tableView.reloadData()
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
