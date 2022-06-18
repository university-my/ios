//
//  UniversitiesListHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class UniversitiesListHostingController: UIHostingController<UniversitiesListView> {
    
    private let model = UniversitiesListViewModel()
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = UniversitiesListView(model: self.model)
        super.init(coder: aDecoder, rootView: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UniversitiesListViewModelDelegate

extension UniversitiesListHostingController: UniversitiesListViewModelDelegate {
    func universitiesListViewModel(didSelectUniversity withID: Int64) {
        dismiss(animated: true)
    }
    
    func universitiesListViewModelDidPressSupportButton() {
        
    }
}
