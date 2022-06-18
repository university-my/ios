//
//  UniversitiesListViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

protocol UniversitiesListViewModelDelegate: AnyObject {
    func universitiesListViewModel(didSelectUniversity withID: Int64)
    func universitiesListViewModelDidPressSupportButton()
}

@MainActor
class UniversitiesListViewModel: ObservableObject {
    internal init(dataProvider: UniversitiesListDataProvider = UniversitiesListDataProvider()) {
        self.dataProvider = dataProvider
    }
    
    typealias Model = University.CodingData
    
    enum State {
        case noData
        case loading
        case presenting(_ data: [Model])
        case failsed(error: Error)
    }
    
    @Published private(set) var state: State = .noData
    @Published var selectedID: Int64? = nil {
        didSet {
            if let selectedID {
                delegate?.universitiesListViewModel(didSelectUniversity: selectedID)
            }
        }
    }
    
    weak var delegate: UniversitiesListViewModelDelegate?
    private let dataProvider: UniversitiesListDataProvider
    private var universities: [Model] = []
    
    func fetchUniversities() async {
        state = .loading
        do {
            let data = try await dataProvider.load()
            update(with: data)
            state = .presenting(universities)
        } catch {
            state = .failsed(error: error)
        }
    }
    
    func update(with data: [Model]) {
        self.universities = data.sorted { $0.id < $1.id }
    }
    
    // MARK: - Search
    
    @Published var searchText = "" {
        didSet {
            if searchText.isEmpty {
                state = .presenting(universities)
            } else {
                let searchResults = universities.filter { university in
                    university.shortName.localizedCaseInsensitiveContains(searchText) ||
                    university.fullName.localizedCaseInsensitiveContains(searchText)
                }
                state = .presenting(searchResults)
            }
        }
    }
    
    // MARK: - Support
    
    func showSupport() {
        delegate?.universitiesListViewModelDidPressSupportButton()
    }
}
