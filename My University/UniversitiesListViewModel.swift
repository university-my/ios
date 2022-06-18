//
//  UniversitiesListViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

@MainActor
class UniversitiesListViewModel: ObservableObject {
    
    enum State {
        case noData
        case loading
        case success(data: [University.CodingData])
        case failsed(error: Error)
    }
    
    @Published private(set) var state: State = .noData
    
    let dataProvider: UniversitiesListDataProvider
    
    internal init(dataProvider: UniversitiesListDataProvider) {
        self.dataProvider = dataProvider
    }
    
    func fetchUniversities() async {
        state = .loading
        do {
            var universities = try await dataProvider.load()
            universities.sort { $0.id < $1.id }
            state = .success(data: universities)
        } catch {
            state = .failsed(error: error)
        }
    }
}
