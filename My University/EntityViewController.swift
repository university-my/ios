//
//  EntityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class EntityViewController: UIViewController {
    
    /// ID of the Auditorium, Group or Teacher
    var entityID: Int64!
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show toolbar
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - State
    
    enum State {
        case loading(showActivity: Bool)
        case presenting(EntityStructRepresentable)
        case failed(Error)
    }
    
    // MARK: - Share
    
    func share(_ url: URL) {
        let sharedItems = [url]
        let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(vc, animated: true)
    }
}
