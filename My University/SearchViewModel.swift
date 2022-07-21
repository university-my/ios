//
//  SearchViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    internal init(universityURL: String) {
        self.universityURL = universityURL
    }
    
    let universityURL: String
    
    let dataProvider = SearchDataProvider()
    
    private var groups: [ModelCodingData] = []
    
    func fetchAll() async {
        do {
            let groups = try await dataProvider.groupsDataProvider.load(universityURL: universityURL)
            print(groups)
        } catch {
            print(error)
        }
    }
}
