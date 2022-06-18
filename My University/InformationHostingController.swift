//
//  InformationHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

protocol InformationHostingControllerDelegate: AnyObject {
    func informationHostingControllerChangeUniversityPressed(in controller: InformationHostingController)
}

class InformationHostingController: UIHostingController<InformationView> {
    
    let model = InformationViewModel(university: University.current)
    weak var delegate: InformationHostingControllerDelegate?
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = InformationView(model: self.model)
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

// MARK: - InformationViewModelDelegate

extension InformationHostingController: InformationViewModelDelegate {
    func informationViewModelChangeUniversityPressed() {
        delegate?.informationHostingControllerChangeUniversityPressed(in: self)
    }
}
