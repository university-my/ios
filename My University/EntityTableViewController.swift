//
//  EntityTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

protocol EntityTableViewControllerDelegate: AnyObject {
    func didBeginRefresh()
    func didDismissDetails()
}

class EntityTableViewController<Kind: ModelKind, Entity: CoreDataFetchable & CoreDataEntityProtocol>: GenericTableViewController {
    typealias ModelType = Model<Kind, Entity>
    
    var entityID: Int64!
    
    weak var delegate: EntityTableViewControllerDelegate?
    
    var dataController: ModelType.TableDataController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NoRecordsTableViewCell.self)
    }
    
    // MARK: - Title
    
    var titleText: String?
    
    // MARK: - Data
    
    func update(with sections: [ModelType.TableDataController.Section]) {
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
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* It's a common anti-pattern to leave a cell labels populated with their text content when these cells enter the reuse queue. */
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
    }
    
    
}

// MARK: - RecordDetailedTableViewControllerDelegate

extension EntityTableViewController: RecordDetailedTableViewControllerDelegate {
    
    func didDismissDetails(in viewController: RecordDetailedTableViewController) {
        delegate?.didDismissDetails()
    }
}
