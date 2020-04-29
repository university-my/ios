//
//  GroupLogicController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol GroupLogicControllerDelegate: class {
    func didChangeState(to newState: GroupViewController.State)
}

class GroupLogicController {
    typealias Handler = (GroupViewController.State) -> Void
    
    // MARK: - Init

    weak var delegate: GroupLogicControllerDelegate?
    private let dataController: GroupDataController
    
    init() {
        dataController = GroupDataController()
        dataController.delegate = self
    }
    
    // MARK: - Data
    
    func fetchData(for groupID: Int64)  {
        dataController.fetchGroup(with: groupID)
        dataController.loadData()
        importRecordsIfNeeded()
    }
    
    func importRecordsIfNeeded() {
        if dataController.needToImportRecords {
            delegate?.didChangeState(to: .loading)
            dataController.importRecordsIfNeeded()
        }
    }
    
    var sections: [GroupDataController.Section] {
        return dataController.sections
    }
    
    // MARK: - Group
    
    var group: GroupEntity? {
        return dataController.group
    }
    
    // MARK: - Favorites
    
    func toggleFavorite() {
        guard let groupEntity = group else { return }
        dataController.toggleFavorite(for: groupEntity)
        
        // TODO: Refactor this
        
        if let group = groupEntity.asStruct() {
            delegate?.didChangeState(to: .presenting(group))
        }
    }
    
    // MARK: - Share URL
    
    func shareURL() -> URL? {
        guard let group = dataController.group else { return nil }
        let date = dataController.pairDate
        return url(for: group, by: date)
    }
    
    private func url(for group: GroupEntity, by date: Date) -> URL? {
        guard let universityURL = group.university?.url else { return nil }
        guard let slug = group.slug else { return nil }
        let dateString = DateFormatter.short.string(from: date)
        return Group.Endpoint.page(for: slug, university: universityURL, date: dateString).url
    }
    
    // MARK: - Date
    
    var pairDate: Date {
        return dataController.pairDate
    }
    
    func previousDate() {
        // -1 day
        let currentDate = dataController.pairDate
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            dataController.changePairDate(to: previousDate)
        }
    }
    
    func nextDate() {
        // +1 day
        let currentDate = dataController.pairDate
        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            dataController.changePairDate(to: nextDate)
        }
    }
    
    func changePairDate(to newDate: Date) {
        dataController.changePairDate(to: newDate)
    }
}

// MARK: - GroupDataControllerDelegate

extension GroupLogicController: GroupDataControllerDelegate {
    
    func groupDataController(didImportRecordsFor group: Group, _ error: Error?) {
        if let error = error {
            delegate?.didChangeState(to: .failed(error))
        }
    }
    
    func groupDataController(didBuildSectionsFor group: Group) {
        delegate?.didChangeState(to: .presenting(group))
    }
}
