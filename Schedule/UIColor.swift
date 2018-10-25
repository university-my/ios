//
//  UIColor.swift
//  Schedule
//
//  Created by Yura Voevodin on 10/25/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIColor {
    
    @objc class var backgroundColor: UIColor {
        return UIColor(named: "Background Color")!
    }
    
    @objc class var cellSelectionColor: UIColor {
        return UIColor(named: "Cell Selection Color")!
    }
    
    @objc class var sectionBackgroundColor: UIColor {
        return UIColor(named: "Section Backgroud Color")!
    }
    
    @objc class var separatorColor: UIColor {
        return UIColor(named: "Separator Color")!
    }
}
