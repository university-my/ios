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
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    guard let window = appDelegate.window else { return }
    window.rootViewController = self.destination
  }
}
