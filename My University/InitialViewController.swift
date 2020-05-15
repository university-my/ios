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
        
        if University.selectedUniversityID == nil {
            // Show all universities
            performSegue(withIdentifier: "setAllUniversities")
            return
        }
        
        guard let entity = Entity.lastOpened else {
            // Show selected university
            performSegue(withIdentifier: "setUniversity")
            return
        }
        
        // Show last opened Auditorium, Group or Teacher
        let tabBarController = UIStoryboard.university.instantiateInitialViewController() as! UITabBarController
        let navigation = tabBarController.viewControllers?.first as! UINavigationController
        let universityViewController = navigation.topViewController as! UniversityViewController
        universityViewController.show(entity)
    }
}
