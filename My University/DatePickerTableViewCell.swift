//
//  DatePickerTableViewCell.swift
//  My University
//
//  Created by Yura Voevodin on 8/21/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

  // MARK: - Cell height

  static let cellHeight: CGFloat = 162

  // MARK: - Date picker

  @IBOutlet weak var datePicker: UIDatePicker!
}
