//
//  SelectUniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SelectUniversityViewController: GenericTableDelegateViewController {

    // MARK: - Properties

    lazy var dataSource: UniversityDataSource = {
        return UniversityDataSource()
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var refreshControl: UIRefreshControl?

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Import on pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)

        // Configure table
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl

        // Loading...
        loadUniversities()
    }

    private func loadUniversities() {
        tableView.dataSource = dataSource
        dataSource.fetchUniversities()

        let universities = dataSource.fetchedResultsController?.fetchedObjects ?? []

        if universities.isEmpty {

            tableView.isHidden = true
            activityIndicator.startAnimating()

            dataSource.importUniversities { (error) in
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }

                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.dataSource.fetchUniversities()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }

        } else {
            tableView.isHidden = false
            tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Pull to refresh

    @objc func refreshContent() {
        loadUniversities()
    }

    // MARK: - Show University

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showUniversity", sender: nil)
    }

    // MARK: - Navigation

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
}
