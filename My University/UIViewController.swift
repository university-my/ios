//
//  UIViewController.swift
//  My University
//
//  Created by Yura Voevodin on 13.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    typealias SegueIdentifier = String
    
    func performSegue(withIdentifier: SegueIdentifier) {
        performSegue(withIdentifier: withIdentifier, sender: nil)
    }
}

// MARK: - StoryboardIdentifiable

extension UIViewController: StoryboardIdentifiable { }
