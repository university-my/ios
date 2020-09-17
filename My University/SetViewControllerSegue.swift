//
//  SetViewControllerSegue.swift
//  My University
//
//  Created by Yura Voevodin on 20.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class SetViewControllerSegue: UIStoryboardSegue {
  
  override func perform() {
    guard let window = UIApplication.shared.currentWindow else { return }
    window.rootViewController = self.destination

    // A mask of options indicating how you want to perform the animations.
    let options: UIView.AnimationOptions = .transitionCrossDissolve

    // The duration of the transition animation, measured in seconds.
    let duration: TimeInterval = 0.2

    // Creates a transition animation.
    // Though `animations` is optional, the documentation tells us that it must not be nil.
    UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in })
  }
}
