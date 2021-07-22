//
//  ActivityController.swift
//  My University
//
//  Created by Yura Voevodin on 30.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

protocol ActivityControllerDelegate: AnyObject {
    func didPresentActivity(from controller: ActivityController)
}

class ActivityController {
    
    weak var delegate: ActivityControllerDelegate?
    
    /// `true` while performing transition animation
    private(set) var isRunningTransitionAnimation = false
    
    /// Reference to the view controller with `UIActivityIndicatorView`
    /// Can be added as child to any  subclass of `ViewController`
    private var activityViewController: ActivityViewController?
    
    func showActivity(in viewController: UIViewController) {
        isRunningTransitionAnimation = true
        
        let child = UIStoryboard.activity.instantiateInitialViewController() as! ActivityViewController
        
        // Add the spinner view controller
        viewController.addChild(child)
        child.view.frame = viewController.view.frame
        
        UIView.transition(with: viewController.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            viewController.view.addSubview(child.view)
            
        }, completion: { (_) in
            child.didMove(toParent: viewController)
            self.activityViewController = child
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isRunningTransitionAnimation = false
                self.delegate?.didPresentActivity(from: self)
            }
        })
    }
    
    func hideActivity() {
        if let child = activityViewController {
            // Remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            
            isRunningTransitionAnimation = false
        }
    }
}
