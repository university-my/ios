//
//  SearchViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    
    private let dataProvider = SearchDataProvider()
    
    private(set) var university: University.CodingData? = nil
    private var groups: [ModelCodingData] = []
    
    func fetchAll() async {
        guard let url = university?.url else { return }
        do {
            let groups = try await dataProvider.groupsDataProvider.load(universityURL: url)
            print(groups)
        } catch {
            print(error)
        }
    }
    
    func update(with university: University.CodingData?) {
        self.university = university
    }
}
