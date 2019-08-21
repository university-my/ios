//
//  ReusableView.swift
//  My University
//
//  Created by Yura Voevodin on 8/21/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

protocol ReusableView: class {}

extension ReusableView where Self: UIView {

  static var reuseIdentifier: String {
    return String(describing: self)
  }
}
