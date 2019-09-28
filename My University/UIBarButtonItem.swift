//
//  UIBarButtonItem.swift
//  My University
//
//  Created by Yura Voevodin on 6/1/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    func markAs(isFavorites: Bool) {
        if isFavorites {
            image = UIImage(systemName: "star.fill")
        } else {
            image = UIImage(systemName: "star")
        }
    }
}
