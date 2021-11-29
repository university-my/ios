//
//  EntityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class EntityViewController<Kind: ModelKind, Entity: CoreDataFetchable & CoreDataEntityProtocol>: UIViewController {
    typealias ModelType = Model<Kind, Entity>
    
    // MARK: - Properties
    
    /// Show an activity indicator over current `UIViewController`
    let activityController = ActivityController()
    
    /// `UITableView`
    var tableViewController: EntityTableViewController<Kind, Entity>!
    
    /// ID of the Classroom, Group or Teacher
    var entityID: Int64!
    
    var logic: ModelType.LogicController!
    
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
    
    // MARK: - Share
    
    func share(_ url: URL) {
        let sharedItems = [url]
        let controller = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(controller, animated: true)
    }
    
    // MARK: - Menu
    
    var menuItem: UIBarButtonItem? {
        nil
    }
    
    var isFavorite: Bool {
        false
    }
    
    private var menuPresenter: EntityMenuPresenter!
    
    func configureMenu() {
        guard let item = menuItem else {
            preconditionFailure()
        }
        let config = EntityMenuPresenter.Config(item: item) {
            if let url = self.logic.shareURL {
                self.share(url)
            }
            
        } favoritesAction: {
            self.logic.dataController.toggleFavorites()
            self.menuPresenter.updateMenu(isFavorite: self.isFavorite)
            
        } universityAction: {
            self.performSegue(withIdentifier: "setUniversity", sender: nil)
        }
        menuPresenter = EntityMenuPresenter(config: config)
        menuPresenter.updateMenu(isFavorite: isFavorite)
    }
    
    // MARK: - State
    
    func render(_ state: EntityViewControllerState) {
        switch state {
            
        case .loading(let showActivity):
            if !activityController.isRunningTransitionAnimation && showActivity {
                // Show a loading spinner
                activityController.showActivity(in: self)
            }
            // Controller title
            title = DateFormatter.date.string(from: pairDate)
            
        case .presenting(let structure):
            // Bind the user model to the view controller's views
            guard let model = structure as? ModelType else {
                preconditionFailure()
            }
            
            // Title
            tableViewController.titleText = model.name
            
            // Controller title
            title = DateFormatter.date.string(from: pairDate)
            
            tableViewController.update(with: logic.sections)
            
            activityController.hideActivity()
            
        case .failed(let error):
            activityController.hideActivity()
            
            presentAnError(error)
            
            tableViewController.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Error
    
    func presentAnError(_ error: Error) {
        if let error = error as? URLError, error.code == .badServerResponse {
            // TODO: Notify user
            
        } else if let networkError = error as? NetworkError, networkError.kind == .scheduleParsingError {
            let alert = configureParsingErrorAlert(with: networkError, website: logic.shareURL)
            present(alert, animated: true)
            
        } else {
            present(error) {
                // Try again
                self.logic.importRecords()
            }
        }
    }
    
    // MARK: - Date
    
    internal var pairDate: Date {
        logic.pairDate
    }
}

// MARK: - EntityTableViewControllerDelegate

extension EntityViewController: EntityTableViewControllerDelegate {
    
    func didBeginRefresh() {
        // Import records on "pull to refresh"
        // Don't show activity indicator in the center of the screen
        logic.importRecords(showActivity: false)
    }
    
    func didDismissDetails() {
        logic.makeReviewRequestIfNeeded()
    }
}

// MARK: - GroupLogicControllerDelegate

extension EntityViewController: ModelLogicControllerDelegate {
    
    func didChangeState(to newState: EntityViewControllerState) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension EntityViewController: ErrorAlertRepresentable {}

// MARK: - State

enum EntityViewControllerState {
    case loading(showActivity: Bool)
    case presenting(EntityRepresentable)
    case failed(Error)
}
