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
    func homeViewModelBeginSearchPressed()
    func homeViewModelPresentInformationPressed()
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var data: ModelData?
    @Published var university: University.CodingData? {
        didSet {
            data = nil
        }
    }
    
    weak var delegate: HomeViewModelDelegate?
    
    func selectUniversity() {
        delegate?.homeViewModelSelectUniversityPressed()
    }
    
    func beginSearch() {
        delegate?.homeViewModelBeginSearchPressed()
    }
    
    func presentInformation() {
        delegate?.homeViewModelPresentInformationPressed()
    }
}
