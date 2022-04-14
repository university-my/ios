//
//  ReusableView.swift
//  My University
//
//  Created by Yura Voevodin on 15.09.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit

public protocol ReusableView: AnyObject {}

public extension ReusableView where Self: UIView {

    static var reuseIdentifier: String {
        String(describing: self)
    }
}
