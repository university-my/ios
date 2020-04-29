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
    
    @IBOutlet weak var tableTitleLabel: UILabel!
    
    // MARK: - Properties
    
    private let logic: GroupLogicController
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = GroupLogicController()
        super.init(coder: coder)
        
        logic.delegate = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table
        configureTableView()
        
        // Data
        logic.fetchData(for: groupID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show toolbar
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - State
    
    enum State {
        case loading
        case presenting(Group)
        case failed(Error)
    }
    
    func render(_ state: State) {
        switch state {
            
        case .loading:
            // Show a loading spinner
            // TODO: Show activity indicator in separate child controller
            break
            
        case .presenting(let group):
            // Bind the user model to the view controller's views
            
            // Title
            tableTitleLabel.text = group.name
            
            // Is Favorites
            favoriteButton.markAs(isFavorites: group.isFavorite)
            
            // Controller title
            title = DateFormatter.date.string(from: pairDate)
            
            tableView.reloadData()
            
        case .failed(let error):
            // Show an error view
            present(error) {
                // Try again
                self.logic.importRecordsIfNeeded()
            }
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Group
    
    var groupID: Int64!
    
    var group: GroupEntity? {
        return logic.group
    }
    
    // MARK: - Table views
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NoRecordsTableViewCell.self)
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        logic.importRecordsIfNeeded()
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let url = logic.shareURL() else { return }
        let sharedItems = [url]
        let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(vc, animated: true)
    }
    
    // MARK: - Favorites
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBAction func toggleFavorite(_ sender: Any) {
        logic.toggleFavorite()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return logic.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logic.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = logic.section(at: indexPath.section)
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
        logic.section(at: section).title
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = logic.record(at: indexPath)
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
                self.logic.changePairDate(to: selectedDate)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Date
    
    private var pairDate: Date {
        logic.pairDate
    }
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    @IBAction func previousDate(_ sender: Any) {
        logic.previousDate()
    }
    
    @IBAction func nextDate(_ sender: Any) {
        logic.nextDate()
    }
}

// MARK: - GroupLogicControllerDelegate

extension GroupTableViewController: GroupLogicControllerDelegate {
    
    func didChangeState(to newState: State) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension GroupTableViewController: ErrorAlertRepresentable {}
