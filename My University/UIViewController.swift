//
//  UIViewController.swift
//  My University
//
//  Created by Yura Voevodin on 13.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func performSegue(withIdentifier: String) {
        performSegue(withIdentifier: withIdentifier, sender: nil)
    }
}
