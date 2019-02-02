//
//  Settings.swift
//  My University
//
//  Created by Yura Voevodin on 2/2/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import Foundation

struct Settings {
  
  static var shared = Settings()
  
  // MARK: - Properties
  
  let baseURL: String
  
  // MARK: - Init
  
  init() {
    let baseURL = Bundle.main.infoDictionary?["SERVER_BASE_URL"] as! String
    self.baseURL = baseURL
  }
}
