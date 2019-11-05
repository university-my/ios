//
//  Bundle.swift
//  My University
//
//  Created by Yura Voevodin on 20.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

extension Bundle {

  /// Identifier of app main bundle
  static var identifier: String {
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      return bundleIdentifier
    } else {
      return "ua.com.my-university"
    }
  }
}
