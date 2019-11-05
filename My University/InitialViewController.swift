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
        
        if let id = University.selectedUniversityID {
            performSegue(withIdentifier: "setUniversity", sender: id)
        } else {
            performSegue(withIdentifier: "setAllUniversities", sender: nil)
        }
    }
}
