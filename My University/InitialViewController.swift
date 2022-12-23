//
//  InitialViewController.swift
//  My University
//
//  Created by Yura Voevodin on 19.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if University.current == nil {
            // Show all universities
            performSegue(withIdentifier: .allUniversities)
        } else {
            // Show selected university
            performSegue(withIdentifier: .selectedUniversity)
        }
    }
    
}

// MARK: - SegueIdentifier

private extension InitialViewController.SegueIdentifier {
    static let allUniversities = "allUniversities"
    static let selectedUniversity = "selectedUniversity"
}
