//
//  DatePickerViewController.swift
//  My University
//
//  Created by Yura Voevodin on 8/22/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class DatePickerViewController: UITableViewController {

  // MARK: - Date

  var selectedDate: Date = Date()
  @IBOutlet weak var datePicker: UIDatePicker!

  func update(with date: Date) {
    datePicker.date = date
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  private func setup() {
    update(with: selectedDate)
  }

  // MARK: - Cancel

  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true)
  }

  // MARK: - Done

  @IBAction func done(_ sender: Any) {
    dismiss(animated: true)
  }
}
