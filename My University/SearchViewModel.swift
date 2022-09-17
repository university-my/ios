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

@MainActor
final class SearchViewModel: ObservableObject {
    
    private(set) var university: University.CodingData? = nil
    
    func update(with university: University.CodingData?) {
        self.university = university
    }
    
    @Published var selectedID: Int64? = nil {
        didSet {}
    }
    
    // MARK: - Fetch data
    
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
    
    func fetchDataIfNeeded() async {
        var needToFetchData = false
        
        switch searchScope {
        case .groups:
            needToFetchData = groups.isEmpty
        case .teachers:
            needToFetchData = teachers.isEmpty
        case .classrooms:
            needToFetchData = classrooms.isEmpty
        }
        if needToFetchData {
            await fetchData()
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
            let classrooms = try await classroomsDataProvider.load(universityURL: url)
            self.classrooms = classrooms
            
        case .groups:
            let groups = try await groupsDataProvider.load(universityURL: url)
            self.groups = groups
            
        case .teachers:
            let teachers = try await teachersDataProvider.load(universityURL: url)
            self.teachers = teachers
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
            Task {
                await fetchDataIfNeeded()
                filterData()
                state = .presenting
            }
        }
    }
    
    @Published var searchText = "" {
        didSet {
            if !searchText.isEmpty {
                Task {
                    await fetchDataIfNeeded()
                    filterData()
                    state = .presenting
                }
            }
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
}
