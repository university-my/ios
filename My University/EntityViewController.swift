//
//  EntityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class EntityViewController<Kind: ModelKind, Entity: CoreDataFetchProtocol & CoreDataEntityProtocol>: UIViewController {
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
        logic.entity?.isFavorite ?? false
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
            self.returnToUniversity()
        }
        menuPresenter = EntityMenuPresenter(config: config)
        menuPresenter.updateMenu(isFavorite: isFavorite)
    }
    
    func returnToUniversity() {
        performSegue(withIdentifier: "setUniversity", sender: nil)
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
            
            presentAlert(with: error)
            
            tableViewController.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Error
    
    func presentAlert(with error: Error) {
        
        switch error {
            
        case URLError.badServerResponse:
            /*
             This error occurs when a user tries to download records for an object that no longer exists.
             This can happen when the database on the server has been reset.
             */
            let alert = configureNotFoundAlert()
            present(alert, animated: true)
            
        case NetworkError.scheduleParsingError:
            /*
             This error occurs when a server can't parse a schedule.
             For example, due to an unexpected structure or special characters.
             */
            let alert = configureParsingErrorAlert(with: error.localizedDescription, website: logic.shareURL)
            present(alert, animated: true)
            
        case LogicError.UUIDNotEqual, LogicError.UUIDNotFound:
            /*
             Update list of entities to get UUID
             */
            let alert = configureUUIDNotFoundAlert(with: error.localizedDescription) {
                
                self.logic.dataController.removeFromFavorites()
                
                UniversityDataController.shared.requestEntitiesUpdate()
                
                self.returnToUniversity()
            }
            present(alert, animated: true)
            
        default:
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
