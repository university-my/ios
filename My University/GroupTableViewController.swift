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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show toolbar
        navigationController?.setToolbarHidden(false, animated: true)
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
    guard let url = groupURL() else { return }
    if let siteURL = URL(string: url) {
      let sharedItems = [siteURL]
      let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
      present(vc, animated: true)
    }
  }

  private func groupURL() -> String? {
    guard let group = group else { return nil }
    guard let universityURL = group.university?.url else { return nil }
    guard let slug = group.slug else { return nil }
    let dateString = DateFormatter.short.string(from: DatePicker.shared.pairDate)
    let url = Settings.shared.baseURL + "/universities/\(universityURL)/groups/\(slug)?pair_date=\(dateString)"
    return url
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
        
        // Download records for Group from backend and save to database.
        let selectedDate = DatePicker.shared.pairDate
        importManager = Record.ImportForGroup(persistentContainer: persistentContainer, group: group, university: university)
        importManager?.importRecords(for: selectedDate, { (error) in
            
            DispatchQueue.main.async {
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
        refreshControl?.endRefreshing()
        performFetch()
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
        let cell = tableView.dequeueReusableCell(for: indexPath) as RecordTableViewCell
        
        // Configure the cell
        if let record = fetchedResultsController?.object(at: indexPath) {
            cell.update(with: record)
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
        performSegue(withIdentifier: "recordDetails", sender: record)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "recordDetails":
            if let navigation = segue.destination as? UINavigationController {
                if let destination = navigation.viewControllers.first as? RecordDetailedTableViewController {
                        destination.recordID = (sender as? RecordEntity)?.id
                        destination.groupID = groupID
                        destination.teacherID = nil
                        destination.auditoriumID = nil
                    }
            }
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? DatePickerViewController
            vc?.selectDate = {
                self.updateDateButton()
                self.fetchOrImportRecordsForSelectedDate()
            }

        case "presentInformation":
          let navigationVC = segue.destination as? UINavigationController
          let vc = navigationVC?.viewControllers.first as? InformationTableViewController
          if let group = group, let url = groupURL() {
            let page = WebPage(url: url, title: group.name ?? "")
            vc?.webPage = page
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
        
        let pairName = NSSortDescriptor(key: #keyPath(RecordEntity.pairName), ascending: true)
        let time = NSSortDescriptor(key: #keyPath(RecordEntity.time), ascending: true)

        request.sortDescriptors = [pairName, time]
        request.predicate = generatePredicate()
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(RecordEntity.pairName), cacheName: nil)
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
                        var sectionName = ""
                        if let name = firstObjectInSection.pairName {
                          sectionName = name
                        }
                        if let time = firstObjectInSection.time {
                          sectionName += " (\(time))"
                        }
                        newSectionsTitles.append(sectionName)
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
    dateButton.title = DateFormatter.date.string(from: selectedDate)
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
