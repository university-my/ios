//
//  UIStoryboard.swift
//  My University
//
//  Created by Yura Voevodin on 02.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var activity: UIStoryboard {
        UIStoryboard(name: "Activity", bundle: nil)
    }
    
    static var legalDocument: UIStoryboard {
        UIStoryboard(name: "Legal Document", bundle: nil)
    }
    
    static var newActivity: UIStoryboard {
        UIStoryboard(name: "NewActivity", bundle: nil)
    }
    
    static var university: UIStoryboard {
        UIStoryboard(name: "University", bundle: nil)
    }
}
