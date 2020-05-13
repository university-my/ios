//
//  GroupViewController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupViewController: EntityViewController {
    
    // MARK: - Properties
    
    private let logic: GroupLogicController
    
    /// `UITableView`
    var tableViewController: GroupTableViewController!
    
    /// Show an activity indicator over current `UIViewController`
    let activityController = ActivityController()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = GroupLogicController(activity: activityController)
        
        super.init(coder: coder)
        
        logic.delegate = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        logic.fetchData(for: entityID)
    }
    
    // MARK: - Group
    
    var group: GroupEntity? {
        return logic.group
    }
    
    // MARK: - State
    
    func render(_ state: State) {
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
            guard let group = structure as? Group else {
                preconditionFailure()
            }
            
            // Title
            tableViewController.tableTitleLabel.text = group.name
            
            // Controller title
            title = DateFormatter.date.string(from: pairDate)
            
            tableViewController.update(with: logic.sections)
            
            activityController.hideActivity()
            
        case .failed(let error):
            activityController.hideActivity()
            
            // Show an error view
            present(error) {
                // Try again
                self.logic.importRecords()
            }
            tableViewController.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Menu
    
    @IBAction func menu(_ sender: Any) {
        guard let url = logic.shareURL() else {
            return
        }
        let favoritesAction = favorites(for: group, data: logic.dataController)
        showMenu(shareURL: url, favorites: favoritesAction)
    }
    
    // MARK: - Date
    
    private var pairDate: Date {
        logic.pairDate
    }
    
    @IBAction func previousDate(_ sender: Any) {
        logic.previousDate()
    }
    
    @IBAction func nextDate(_ sender: Any) {
        logic.nextDate()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "records":
            let vc = segue.destination as! GroupTableViewController
            tableViewController = vc
            tableViewController.delegate = self
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let vc = navigationVC?.viewControllers.first as? DatePickerViewController
            vc?.pairDate = pairDate
            vc?.didSelectDate = { selectedDate in
                self.logic.changePairDate(to: selectedDate)
            }
            
        default:
            break
        }
    }
}

// MARK: - GroupTableViewControllerDelegate

extension GroupViewController: EntityTableViewControllerDelegate {
    
    func didBeginRefresh(in viewController: EntityTableViewController) {
        // Import records on "pull to refresh"
        // Don't show activity indicator in the center of the screen
        logic.importRecords(showActivity: false)
    }
}

// MARK: - GroupLogicControllerDelegate

extension GroupViewController: EntityLogicControllerDelegate {
    
    func didChangeState(to newState: EntityViewController.State) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension GroupViewController: ErrorAlertRepresentable {}
