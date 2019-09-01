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
    var selectDate: ((_ date: Date) -> ())?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = selectedDate
    }
    
    // MARK: - Cancel
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        selectDate?(datePicker.date)
        dismiss(animated: true)
    }
}
