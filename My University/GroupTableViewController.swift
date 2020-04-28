//
//  GroupTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class GroupTableViewController: GenericTableViewController {
    
    // MARK: - Properties
    
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
        // Data source
        setupDataSource(with: groupID)
        dataSource.fetchRecords()
        dataSource.rebuild()
        
        configureTableView()
        updateTitleWithDate()
        
        if dataSource.fetchedRecords.isEmpty {
            // Show activity indicator
            showActivity()
        } else {
            #warning("Fix a bug with activity indicator")
            tableView.reloadData()
        }
        
        // Start import
        dataSource.importRecords()
        
        if let group = group {
            titleLabel.text = group.name
            
            // Is Favorites
            favoriteButton.markAs(isFavorites: group.isFavorite)
        }
    }
    
    // MARK: - Group
    
    var groupID: Int64!
    
    // TODO: Change to Struct
    var group: GroupEntity? {
        return dataSource.group
    }
    
    // MARK: - Data Source
    
    var dataSource: GroupDataSource!
    
    private func setupDataSource(with groupID: Int64) {
        dataSource = GroupDataSource(groupID: groupID)
        dataSource.delegate = self
        dataSource.fetchGroup()
    }
    
    // MARK: - Table views
    
    private func configureTableView() {
        tableView.register(NoRecordsTableViewCell.self)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        dataSource.importRecords()
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let url = dataSource.groupURL() else { return }
        if let siteURL = URL(string: url) {
            let sharedItems = [siteURL]
            let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
    // MARK: - Favorites
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if let group = group {
            dataSource.toggleFavorite(for: group)
            favoriteButton.markAs(isFavorites: group.isFavorite)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSource.sections[section].kind {
        case .noRecords:
            return 1
        case .records(let records, _):
            return records.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataSource.sections[indexPath.section]
        switch section.kind {
            
        case .noRecords:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NoRecordsTableViewCell
            // TODO: Pick random image
            return cell
            
        case .records(let records, _):
            let cell = tableView.dequeueReusableCell(for: indexPath) as RecordTableViewCell
            let record = records[indexPath.row]
            cell.update(with: record)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.sections[section].title
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = dataSource.record(at: indexPath)
        performSegue(withIdentifier: "recordDetails", sender: record)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "recordDetails":
            if let navigation = segue.destination as? UINavigationController {
                if let destination = navigation.viewControllers.first as? RecordDetailedTableViewController {
                    destination.recordID = (sender as? Record)?.id
                    destination.groupID = groupID
                    destination.teacherID = nil
                    destination.auditoriumID = nil
                }
            }
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? DatePickerViewController
            vc?.pairDate = pairDate
            vc?.didSelectDate = { selectedDate in
                self.pairDate = selectedDate
                self.updateTitleWithDate()
                self.fetchOrImportRecordsForSelectedDate()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Date
    
    private var pairDate: Date {
        get {
            return dataSource.pairDate
        }
        set {
            dataSource.pairDate = newValue
        }
    }
    
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
        dataSource.updateDatePredicate()
        dataSource.fetchRecords()
        dataSource.rebuild()
        
        if dataSource.fetchedRecords.isEmpty {
            
            // Hide previous records or activity
            hideActivity()
            tableView.reloadData()
            
            // Show activity indicator
            showActivity()
            
            // Start import
            dataSource.importRecords()
        } else {
            hideActivity()
            tableView.reloadData()
        }
    }
}

// MARK: - GroupDataSourceDelegate

extension GroupTableViewController: GroupDataSourceDelegate {
    
    func didImportRecords(_ error: Error?) {
        refreshControl?.endRefreshing()
        
        if let error = error {
            
            // TODO: Test UI with error
            
            show(message: error.localizedDescription)
            return
        }
        
        hideActivity()
        dataSource.fetchRecords()
        dataSource.rebuild()
        
        tableView.reloadData()
    }
}
