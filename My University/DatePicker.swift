//
//  DatePicker.swift
//  My University
//
//  Created by Yura Voevodin on 9/10/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

class DatePicker: NSObject {

  static let shared = DatePicker()

  /// Can't init is singleton
  private override init() { }

  var pairDate: Date = Date()
}
