//
//  StoryboardIdentifiable.swift
//  My University
//
//  Created by Yura Voevodin on 15.09.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit

public protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

public extension StoryboardIdentifiable where Self: UIViewController {

    static var storyboardIdentifier: String {
        String(describing: self)
    }
}
