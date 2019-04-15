//
//  University.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct University {

  // MARK: - Properties

  let fullName: String
  let shortName: String
  let url: String

  // MARK: - Init

  init?(_ json: [String: Any]) {
    guard let fullName = json["full_name"] as? String else { return nil }
    guard let shortName = json["short_name"] as? String else { return nil }
    guard let url = json["url"] as? String else { return nil }

    self.fullName = fullName
    self.shortName = shortName
    self.url = url
  }
}
