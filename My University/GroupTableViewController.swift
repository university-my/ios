//
//  GroupTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupTableViewController: GenericTableViewController {
    
    private let dataController = GroupTableDataController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NoRecordsTableViewCell.self)
    }
    
    // MARK: - Group
    
    var groupID: Int64!
    
    // MARK: - Title
    
    @IBOutlet weak var tableTitleLabel: UILabel!
    
    // MARK: - Data
    
    func update(with sections: [GroupDataController.Section]) {
        dataController.update(with: sections)
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
//        logic.importRecordsIfNeeded()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataController.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataController.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataController.sections[indexPath.section]
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
        dataController.sections[section].title
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = dataController.record(at: indexPath)
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
            
        default:
            break
        }
    }
}
