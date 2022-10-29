//
//  SearchViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

enum SearchScope: String, CaseIterable {
    case groups, classrooms, teachers
}

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
            case .groups:
                data = groups.first { $0.id == selectedID }
            case .classrooms:
                data = classrooms.first { $0.id == selectedID }
            case .teachers:
                data = teachers.first { $0.id == selectedID }
            }
            guard let data = data else { return }
            delegate?.searchViewModel(didSelectModel: ModelData(data: data, type: .group))
        }
    }
    
    // MARK: - Data
    
    var data: [ModelCodingData] {
        switch searchScope {
        case .groups:
            return searchText.isEmpty ? groups : filteredGroups
        case .teachers:
            return searchText.isEmpty ? teachers : filteredTeachers
        case .classrooms:
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
        case .classrooms:
            classrooms = try await classroomsDataProvider.load(universityURL: url)
            
        case .groups:
            groups = try await groupsDataProvider.load(universityURL: url)
            
        case .teachers:
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
    
    @Published var searchScope: SearchScope = .groups {
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
            
        case .classrooms:
            filteredClassrooms = classrooms.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
            
        case .teachers:
            filteredTeachers = teachers.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
            
        case .groups:
            filteredGroups = groups.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func needToFetchData() -> Bool {
        var fetchData = false
        
        switch searchScope {
        case .groups:
            fetchData = groups.isEmpty
        case .teachers:
            fetchData = teachers.isEmpty
        case .classrooms:
            fetchData = classrooms.isEmpty
        }
        
        return fetchData
    }
}
