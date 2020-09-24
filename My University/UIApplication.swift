//
//  UIApplication.swift
//  My University
//
//  Created by Yura Voevodin on 26.06.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    }
}
