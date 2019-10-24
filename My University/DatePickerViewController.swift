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

    var pairDate = Date()
    var didSelectDate: ((_ date: Date) -> ())?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateCell: UITableViewCell!

    @IBAction func didChangeDate(_ sender: Any) {
      updateDateCell()
    }

    private func updateDateCell() {
      let dateString = DateFormatter.date.string(from: datePicker.date)
      dateCell.textLabel?.text = dateString
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = pairDate
        updateDateCell()
    }
    
    // MARK: - Cancel
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        pairDate = datePicker.date
        didSelectDate?(pairDate)
        dismiss(animated: true)
    }
}
