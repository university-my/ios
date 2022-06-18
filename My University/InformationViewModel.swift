//
//  InformationViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

protocol InformationViewModelDelegate: AnyObject {
    func informationViewModelChangeUniversityPressed()
}

@MainActor
class InformationViewModel: ObservableObject {
    typealias Model = University.CodingData
    @Published private(set) var university: Model?
 
    weak var delegate: InformationViewModelDelegate?
    
    func changeUniversity() {
        delegate?.informationViewModelChangeUniversityPressed()
    }
}
