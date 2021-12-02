//
//  NibLoadableView.swift
//  My University
//
//  Created by Yura Voevodin on 15.09.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit

public protocol NibLoadableView: AnyObject { }

public extension NibLoadableView where Self: UIView {

    static var nibName: String {
        return String(describing: self)
    }
}
