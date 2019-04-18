//
//  SelectUniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SelectUniversityViewController: UITableViewController {

    // MARK: - Properties

    lazy var dataSource: UniversityDataSource = {
        return UniversityDataSource()
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStatusLabel()
        
        // Configure table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        // Loading...
        tableView.dataSource = dataSource
        loadUniversities()
    }
    
    // MARK: - Universities

    private func loadUniversities() {
        dataSource.fetchUniversities()
        
        let universities = dataSource.fetchedResultsController?.fetchedObjects ?? []
        if universities.isEmpty {
            
            importUniversities()
        } else {
            tableView.reloadData()
        }
    }
    
    private func importUniversities() {
        let text = NSLocalizedString("Loading universities ...", comment: "")
        updateStatus(text: text)
        
        dataSource.importUniversities { (error) in
            if let error = error {
                self.refreshControl?.endRefreshing()
                self.updateStatus(text: error.localizedDescription)
            } else {
                self.dataSource.fetchUniversities()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.updateStatus(text: nil)
            }
        }
    }

    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        importUniversities()
    }
    
    // MARK: - Notificaion
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    private var statusLabel = UILabel(frame: CGRect.zero)
    
    func addStatusLabel() {
        statusLabel.sizeToFit()
        statusLabel.backgroundColor = .clear
        statusLabel.textAlignment = .center
        statusLabel.textColor = .lightGray
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.5
        statusButton.customView = statusLabel
    }
    
    func updateStatus(text: String?) {
        statusLabel.text = text
        statusLabel.sizeToFit()
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showUniversity", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {

        case "showUniversity":
            let destination = segue.destination as? UniversityViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedUniversity = dataSource.fetchedResultsController?.object(at: indexPath)
                destination?.university = selectedUniversity
            }

        default:
            break
        }
    }
    
    // MARK: - Styling
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
}
