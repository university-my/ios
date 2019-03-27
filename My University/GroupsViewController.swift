//
//  GroupsViewController.swift
//  My University
//
//  Created by Yura Voevodin on 3/27/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupsViewController: GenericTableDelegateViewController {

    // MARK: - Properties

    private lazy var groupDataSource: GroupDataSource = {
        return GroupDataSource()
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true

        // Loading...
        loadGroups()
    }

    // MARK: - Groups

    private func loadGroups() {
        tableView.dataSource = groupDataSource
        groupDataSource.performFetch()

        let groups = groupDataSource.fetchedResultsController?.fetchedObjects ?? []

        if groups.isEmpty {

            tableView.isHidden = true
            activityIndicator.startAnimating()

            groupDataSource.importGroups { (error) in

                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.groupDataSource.performFetch()
                self.tableView.reloadData()
            }
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
