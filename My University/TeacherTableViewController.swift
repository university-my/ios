//
//  TeacherTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class TeacherTableViewController: GenericTableViewController {
    
    // MARK: - Properties
    
    private var sectionsTitles: [String] = []
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        updateTitleWithDate()
        
        if let id = teacherID, let context = viewContext {
            teacher = TeacherEntity.fetchTeacher(id: id, context: context)
        }
        
        if let teacher = teacher {
            titleLabel.text = teacher.name
            
            // Is Favorites
            favoriteButton.markAs(isFavorites: teacher.isFavorite)
            
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
        guard let url = teacherURL() else { return }
        if let siteURL = URL(string: url) {
            let sharedItems = [siteURL]
            let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    private func teacherURL() -> String? {
        guard let teacher = teacher else { return nil }
        guard let universityURL = teacher.university?.url else { return nil }
        guard let slug = teacher.slug else { return nil }
        let dateString = DateFormatter.short.string(from: pairDate)
        let url = Settings.shared.baseURL + "/universities/\(universityURL)/teachers/\(slug)?pair_date=\(dateString)"
        return url
    }
    
    // MARK: - Favorites
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if let teacher = teacher {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            teacher.isFavorite.toggle()
            appDelegate?.saveContext()
            favoriteButton.markAs(isFavorites: teacher.isFavorite)
        }
    }
    
    // MARK: - Import Records
    
    private var teacher: TeacherEntity?
    var teacherID: Int64?
    
    private var importManager: Record.ImportForTeacher?
    
    private func importRecords() {
        // Do nothing without CoreData.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let persistentContainer = appDelegate?.persistentContainer else { return }
        
        guard let teacher = teacher else { return }
        guard let university = teacher.university else { return }
        
        // Download records for Teacher from backend and save to database.
        importManager = Record.ImportForTeacher(persistentContainer: persistentContainer, teacher: teacher, university: university)
        importManager?.importRecords(for: pairDate, { (error) in
            
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
        return numberOfSections()
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
                    destination.teacherID = teacherID
                    destination.auditoriumID = nil
                    destination.groupID = nil
                }
            }
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? DatePickerViewController
            vc?.pairDate = pairDate
            vc?.didSelectDate = { selecteDate in
                self.pairDate = selecteDate
                self.updateTitleWithDate()
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
        guard let teacher = teacher else { return nil }
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        let pairName = NSSortDescriptor(key: #keyPath(RecordEntity.pairName), ascending: true)
        let date = NSSortDescriptor(key: #keyPath(RecordEntity.date), ascending: true)
        
        request.sortDescriptors = [pairName, date]
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
        guard let teacher = teacher else { return nil }
        let selectedDate = pairDate
        
        let startOfDay = selectedDate.startOfDay as NSDate
        let endOfDay = selectedDate.endOfDay as NSDate
        
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
        let teacherPredicate = NSPredicate(format: "teacher == %@", teacher)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [teacherPredicate, datePredicate])
        return compoundPredicate
    }
    
    // MARK: - Sections
    
    // Number of sections in data source
    private func numberOfSections() -> Int {
        let sectionsWithData = fetchedResultsController?.sections?.count ?? 0
        return sectionsWithData
    }
    
    // MARK: - Date
    
    private var pairDate = Date()
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    private func updateTitleWithDate() {
        title = DateFormatter.date.string(from: pairDate)
    }
    
    @IBAction func previousDate(_ sender: Any) {
        // -1 day
        let currentDate = pairDate
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            pairDate = previousDate
            fetchOrImportRecordsForSelectedDate()
            updateTitleWithDate()
        }
    }
    
    @IBAction func nextDate(_ sender: Any) {
        // +1 day
        let currentDate = pairDate
        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            pairDate = nextDate
            fetchOrImportRecordsForSelectedDate()
            updateTitleWithDate()
        }
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
