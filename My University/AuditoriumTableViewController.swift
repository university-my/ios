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

    private var sectionsTitles: [String] = []

    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For notifications
        configureNotificationLabel()
        statusButton.customView = notificationLabel
        
        tableView.rowHeight = UITableView.automaticDimension
        
        setup()
    }
    
    func setup() {
        if let id = auditoriumID, let context = viewContext {
            auditorium = AuditoriumEntity.fetch(id: id, context: context)
        }
        
        if let auditorium = auditorium {
            title = auditorium.name

            // Is Favorites
            favoriteButton.markAs(isFavorites: auditorium.isFavorite)

            // Records
            performFetch()

            let records = fetchedResultsController?.fetchedObjects ?? []
            if records.isEmpty {
                importRecords()
            }
        }
    }
  
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        importRecords()
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let auditorium = auditorium else { return }
        guard let universityURL = auditorium.university?.url else { return }
        guard let slug = auditorium.slug else { return }
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/auditoriums/\(slug)"
        if let siteURL = URL(string: url) {
            let sharedItems = [siteURL]
            let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    // MARK: - Favorites
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if let auditorium = auditorium {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            auditorium.isFavorite.toggle()
            appDelegate?.saveContext()
            favoriteButton.markAs(isFavorites: auditorium.isFavorite)
        }
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
        
        let text = NSLocalizedString("Loading records...", comment: "")
        showNotification(text: text)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Download records for Auditorium from backend and save to database.
        importManager = Record.ImportForAuditorium(persistentContainer: persistentContainer, auditoriumID: auditoriumID, universityURL: universityURL)
        DispatchQueue.global().async {
            self.importManager?.importRecords({ (error) in
                
                DispatchQueue.main.async {

                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    self.processResultOfImport(error: error)
                }
            })
        }
    }
    
    private func processResultOfImport(error: Error?) {
        if let error = error {
            showNotification(text: error.localizedDescription)
        } else {
            hideNotification()
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
                destination.auditoriumID = auditoriumID
                destination.teacherID = nil
                destination.groupID = nil
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

        request.sortDescriptors = [dateString, time]
        request.predicate = NSPredicate(format: "auditorium == %@", auditorium)
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
