//
//  University+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import SwiftUI

extension University {
    
    struct CodingData: Codable, Hashable {
        
        internal init(id: Int64, fullName: String, shortName: String, url: String = "", isHidden: Bool = false, isBeta: Bool = false, logoLight: String?, logoDark: String?, showClassrooms: Bool = true, showGroups: Bool  = true, showTeachers: Bool = true) {
            self.id = id
            self.fullName = fullName
            self.shortName = shortName
            self.url = url
            self.isHidden = isHidden
            self.isBeta = isBeta
            self.logoLight = logoLight
            self.logoDark = logoDark
            self.showClassrooms = showClassrooms
            self.showGroups = showGroups
            self.showTeachers = showTeachers
        }
        
        let id: Int64
        let fullName: String
        let shortName: String
        let url: String
        let isHidden: Bool
        let isBeta: Bool
        let logoLight: String?
        let logoDark: String?
        let showClassrooms: Bool
        let showGroups: Bool
        let showTeachers: Bool
    }
}

extension University.CodingData {
    
    var serverID: Int64 {
        id
    }
    
    // MARK: - Logo
    
    func logo(for colorScheme: ColorScheme) -> URL? {
        colorScheme == .dark ? url(for: logoLight) : url(for: logoDark)
    }
    
    private func url(for image: String?) -> URL? {
        if let image, !image.isEmpty {
            return University.Endpoints.logo(name: image).url
        }
        return nil
    }
}
