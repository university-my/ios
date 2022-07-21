//
//  SearchViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    
    enum State {
        case noData
        case loading
        case presenting
        case failed(error: Error)
    }
    
    @Published private(set) var state: State = .noData
    @Published var selectedID: Int64? = nil {
        didSet {}
    }
    
    private let dataProvider = SearchDataProvider()
    
    private(set) var university: University.CodingData? = nil
    
    private var groups: [ModelCodingData] = []
    private var filteredGroups: [ModelCodingData] = []
    
    var data: [ModelCodingData] {
        searchText.isEmpty ? groups : filteredGroups
    }
    
    func fetchAll() async {
        guard let url = university?.url else { return }
        state = .loading
        do {
            let groups = try await dataProvider.groupsDataProvider.load(universityURL: url)
            self.groups = groups
            state = .presenting
        } catch {
            state = .failed(error: error)
        }
    }
    
    func update(with university: University.CodingData?) {
        self.university = university
    }
    
    // MARK: - Search
    
    @Published var searchText = "" {
        didSet {
            if !searchText.isEmpty {
                filteredGroups = groups.filter { group in
                    group.name.localizedCaseInsensitiveContains(searchText)
                }
            }
            state = .presenting
        }
    }
}
