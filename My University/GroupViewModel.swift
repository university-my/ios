//
//  GroupViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 30.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

@MainActor
final class GroupViewModel: ObservableObject {
    @Published private(set) var model: ModelData
    
    private(set) var university: University.CodingData
    private let dataProvider = Group.DataProvider()
    
    init(model: ModelData, university: University.CodingData) {
        self.model = model
        self.university = university
        self.recordsList = Record.RecordsList(records: [], model: model.data)
    }
    
    // MARK: - Records
    
    private(set) var recordsList: Record.RecordsList
    
    func fetchData() async {
        state = .loading
        do {
            recordsList = try await dataProvider.records(
                modelID: model.data.id,
                universityURL: university.url,
                date: Date()
            )
            state = .presenting
        } catch {
            state = .failed(error: error)
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
}
