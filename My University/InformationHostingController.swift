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
    
    let model = InformationViewModel()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - InformationViewModelDelegate

extension InformationHostingController: InformationViewModelDelegate {
    func informationViewModelChangeUniversityPressed() {
        delegate?.informationHostingControllerChangeUniversityPressed(in: self)
    }
}
