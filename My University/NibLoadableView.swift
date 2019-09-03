//
//  NibLoadableView.swift
//  My University
//
//  Created by Yura Voevodin on 8/21/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {

  static var nibName: String {
    return String(describing: self)
  }
}
