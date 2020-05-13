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
        case presenting(EntityRepresentable)
        case failed(Error)
    }
    
    // MARK: - Share
    
    func share(_ url: URL) {
        let sharedItems = [url]
        let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(vc, animated: true)
    }
    
    // MARK: - Menu
    
    func showMenu(shareURL: URL, favorites: UIAlertAction?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Share
        let shareTitle = NSLocalizedString("Share", comment: "Action title")
        let shareAction = UIAlertAction(title: shareTitle, style: .default) { (_) in
            self.share(shareURL)
        }
        alert.addAction(shareAction)
        
        // Favorites
        if let favoritesAction = favorites {
            alert.addAction(favoritesAction)
        }        
        
        // University
        let universityTitle = NSLocalizedString("Go to University", comment: "Action title")
        let universityAction = UIAlertAction(title: universityTitle, style: .default) { (_) in
            self.performSegue(withIdentifier: "setUniversity", sender: nil)
        }
        alert.addAction(universityAction)
        
        // Cancel
        let cancelTitle = NSLocalizedString("Cancel", comment: "Action title")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func favorites(for entity: EntityProtocol?, data dataController: EntityDataController) -> UIAlertAction? {
        guard let entity = entity else {
            return nil
        }
        let favoritesTitle: String
        if entity.favorite {
            favoritesTitle = NSLocalizedString("Remove from favorites", comment: "Action title")
        } else {
            favoritesTitle = NSLocalizedString("Add to favorites", comment: "Action title")
        }
        let action = UIAlertAction(title: favoritesTitle, style: .default) { (_) in
            dataController.toggleFavorites()
        }
        return action
    }
}
