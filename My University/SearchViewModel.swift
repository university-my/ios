//
//  SearchViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

protocol SearchViewModelDelegate: AnyObject {
    func searchViewModel(didSelectModel data: ModelData)
}

@MainActor
final class SearchViewModel: ObservableObject {
    
    weak var delegate: SearchViewModelDelegate?
    
    private(set) var university: University.CodingData? = nil
    
    func update(with university: University.CodingData?) {
        self.university = university
    }
    
    @Published var selectedID: Int64? = nil {
        didSet {
            guard let selectedID else { return }
            let data: ModelCodingData?
            switch searchScope {
            case .group:
                data = groups.first { $0.id == selectedID }
            case .classroom:
                data = classrooms.first { $0.id == selectedID }
            case .teacher:
                data = teachers.first { $0.id == selectedID }
            }
            guard let data = data else { return }
            delegate?.searchViewModel(didSelectModel: ModelData(data: data, type: searchScope))
        }
    }
    
    // MARK: - Data
    
    var data: [ModelCodingData] {
        switch searchScope {
        case .group:
            return searchText.isEmpty ? groups : filteredGroups
        case .teacher:
            return searchText.isEmpty ? teachers : filteredTeachers
        case .classroom:
            return searchText.isEmpty ? classrooms : filteredClassrooms
        }
    }
    
    func fetchData() async {
        state = .loading
        do {
            try await fetchDataForScope()
            state = .presenting
        } catch {
            state = .failed(error: error)
        }
    }
    
    func resetSearch() {
        state = .noData
    }
    
    private func fetchDataForScope() async throws {
        guard let url = university?.url else { return }
        
        switch searchScope {
        case .classroom:
            classrooms = try await classroomsDataProvider.load(universityURL: url)
            
        case .group:
            groups = try await groupsDataProvider.load(universityURL: url)
            
        case .teacher:
            teachers = try await teachersDataProvider.load(universityURL: url)
        }
    }
    
    // MARK: - State
    
    enum State {
        case noData
        case loading
        case presenting
        case failed(error: Error)
    }
    
    @Published private(set) var state: State = .presenting
    
    // MARK: - Groups
    
    private var groups: [ModelCodingData] = []
    private var filteredGroups: [ModelCodingData] = []
    private let groupsDataProvider = Group.DataProvider()
    
    // MARK: - Teachers
    
    private var teachers: [ModelCodingData] = []
    private var filteredTeachers: [ModelCodingData] = []
    private let teachersDataProvider = Teacher.DataProvider()
    
    // MARK: - Classrooms
    
    private var classrooms: [ModelCodingData] = []
    private var filteredClassrooms: [ModelCodingData] = []
    private let classroomsDataProvider = Classroom.DataProvider()
    
    // MARK: - Search
    
    @Published var searchScope: ModelType = .group {
        didSet {
            performSearch()
        }
    }
    
    @Published var searchText = "" {
        didSet {
            if !searchText.isEmpty {
                performSearch()
            }
        }
    }
    
    private func performSearch() {
        if needToFetchData() {
            state = .loading
            Task {
                do {
                    try await fetchDataForScope()
                    filterData()
                    state = .presenting
                } catch {
                    state = .failed(error: error)
                }
            }
        } else {
            filterData()
            state = .presenting
        }
    }
    
    private func filterData() {
        switch searchScope {
            
        case .classroom:
            filteredClassrooms = classrooms.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
            
        case .teacher:
            filteredTeachers = teachers.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
            
        case .group:
            filteredGroups = groups.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func needToFetchData() -> Bool {
        var fetchData = false
        
        switch searchScope {
        case .group:
            fetchData = groups.isEmpty
        case .teacher:
            fetchData = teachers.isEmpty
        case .classroom:
            fetchData = classrooms.isEmpty
        }
        
        return fetchData
    }
}
