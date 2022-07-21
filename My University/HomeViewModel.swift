//
//  HomeViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func homeViewModelSelectUniversityPressed()
}

@MainActor
class HomeViewModel: ObservableObject {
    typealias Model = University.CodingData
    @Published private(set) var university: Model?
    
    weak var delegate: HomeViewModelDelegate?
    
    func update(with university: Model) {
        self.university = university
    }
    
    func selectUniversity() {
        delegate?.homeViewModelSelectUniversityPressed()
    }
}