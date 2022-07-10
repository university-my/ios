//
//  UniversitiesListHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

protocol UniversitiesListHostingControllerDelegate: AnyObject {
    func universitiesListHostingController(didSelectUniversity university: University.CodingData)
}

class UniversitiesListHostingController: UIHostingController<UniversitiesListView> {
    
    weak var delegate: UniversitiesListHostingControllerDelegate?
    
    private let model = UniversitiesListViewModel()
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = UniversitiesListView(model: self.model)
        super.init(coder: aDecoder, rootView: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
    }
}

// MARK: - UniversitiesListViewModelDelegate

extension UniversitiesListHostingController: UniversitiesListViewModelDelegate {
    func universitiesListViewModel(didSelectUniversity university: University.CodingData) {
        delegate?.universitiesListHostingController(didSelectUniversity: university)
        dismiss(animated: true)
    }
    
    func universitiesListViewModelDidPressSupportButton() {
        
    }
}
