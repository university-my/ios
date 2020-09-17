//
//  EntityMenuPresenter.swift
//  My University
//
//  Created by Yura Voevodin on 26.06.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class EntityMenuPresenter {
    
    private var config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    func updateMenu(isFavorite: Bool) {
        let actions = [share, toggleFavorites(isFavorite: isFavorite), showUniversity]
        config.item.menu = UIMenu(title: "", children: actions)
    }
    
    private lazy var share: UIAction = {
        UIAction(
            title: NSLocalizedString("Share", comment: "Action title"),
            image: UIImage(systemName: "square.and.arrow.up")
        ) { _ in
            self.config.shareAction()
        }
    }()
    
    private func toggleFavorites(isFavorite: Bool) -> UIAction {
        // Title
        let title: String
        if isFavorite {
            title = NSLocalizedString("Remove from favorites", comment: "Action title")
        } else {
            title = NSLocalizedString("Add to favorites", comment: "Action title")
        }
        // Image
        let imageName = isFavorite ? "star.fill" : "star"
        
        return UIAction(
            title: title,
            image: UIImage(systemName: imageName)
        ) { _ in
            self.config.favoritesAction()
        }
    }
    
    private lazy var showUniversity: UIAction = {
        UIAction(
            title: NSLocalizedString("Go to University", comment: "Action title"),
            image: UIImage(systemName: "house")
        ) { _ in
            self.config.universityAction()
        }
    }()
}

// MARK: - Config

extension EntityMenuPresenter {
    
    class Config {
        var item: UIBarButtonItem
        
        // MARK: Actions
        
        var shareAction: (() -> Void)
        var favoritesAction: (() -> Void)
        var universityAction: (() -> Void)
        
        // MARK: - Init
        
        init(item: UIBarButtonItem, shareAction: @escaping (() -> Void), favoritesAction: @escaping (() -> Void), universityAction: @escaping (() -> Void)) {
            self.item = item
            self.shareAction = shareAction
            self.favoritesAction = favoritesAction
            self.universityAction = universityAction
        }
    }
}
