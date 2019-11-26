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
  private let apiPrefix: String
  let apiURL: String
  
  // MARK: - Init
  
  private init() {
    // Base URL
    let baseURL = Bundle.main.infoDictionary?["SERVER_BASE_URL"] as! String
    self.baseURL = baseURL

    // API prefix
    let apiPrefix = Bundle.main.infoDictionary?["API_PREFIX"] as! String
    self.apiPrefix = apiPrefix

    // Full API URL
    self.apiURL = baseURL + apiPrefix
  }
}
