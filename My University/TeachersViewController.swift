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

    lazy var teacherDataSource: TeacherDataSource = {
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

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {

    case "showTeacherSchedule":
      if let destination = segue.destination as? TeacherScheduleTableViewController {
        if let indexPath = tableView.indexPathForSelectedRow {
          let selectedTeacher = teacherDataSource.fetchedResultsController?.object(at: indexPath)
          destination.teacher = selectedTeacher
        }
      }

    default:
      break
    }
  }
}

extension TeachersViewController {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "showTeacherSchedule", sender: nil)
  }
}
