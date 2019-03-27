//
//  TeachersViewController.swift
//  My University
//
//  Created by Yura Voevodin on 3/27/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class TeachersViewController: GenericTableDelegateViewController {

    // MARK: - Properties

    private lazy var teacherDataSource: TeacherDataSource = {
        return TeacherDataSource()
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
        loadTeachers()
    }

    private func loadTeachers() {
        tableView.dataSource = teacherDataSource
        teacherDataSource.fetchTeachers()

        let teachers = teacherDataSource.fetchedResultsController?.fetchedObjects ?? []

        if teachers.isEmpty {

            tableView.isHidden = true
            activityIndicator.startAnimating()

            teacherDataSource.importTeachers { (error) in
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }

                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.teacherDataSource.fetchTeachers()
                self.tableView.reloadData()
            }

        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
