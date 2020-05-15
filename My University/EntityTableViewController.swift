//
//  EntityTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

protocol EntityTableViewControllerDelegate: class {
    func didBeginRefresh(in viewController: EntityTableViewController)
}

class EntityTableViewController: GenericTableViewController {
    
    var entityID: Int64!
    
    weak var delegate: EntityTableViewControllerDelegate?
    
    var dataController: EntityTableDataController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NoRecordsTableViewCell.self)
    }
    
    // MARK: - Data
    
    func update(with sections: [EntityTableDataController.Section]) {
        dataController.update(with: sections)
        refreshControl?.endRefreshing()
        tableView.reloadData()
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
            cell.updateWithRandomImage()
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
        if let record = dataController.record(at: indexPath) {
            performSegue(withIdentifier: "recordDetails", sender: record)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
