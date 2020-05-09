//
//  AuditoriumViewController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class AuditoriumViewController: EntityViewController {
    
    // MARK: - Init
    
    private let logic: AuditoriumLogicController
    
    /// `UITableView`
    var tableViewController: NewAuditoriumTableViewController!
    
    /// Show an activity indicator over current `UIViewController`
    let activityController = ActivityController()
    
    required init?(coder: NSCoder) {
        logic = AuditoriumLogicController(activity: activityController)
        
        super.init(coder: coder)

        logic.delegate = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        logic.fetchData(for: entityID)
    }
    
    // MARK: - Auditorium
    
    var auditorium: AuditoriumEntity? {
        return logic.auditorium
    }
    
    // MARK: - State
    
    func render(_ state: State) {
        switch state {
            
        case .loading(let showActivity):
            if showActivity {
                // Show a loading spinner
                activityController.showActivity(in: self)
            }
            
        case .presenting(let structure):
            // Bind the user model to the view controller's views
            guard let auditorium = structure as? Auditorium else {
                preconditionFailure()
            }
            
            // Title
            tableViewController.tableTitleLabel.text = auditorium.name
            
            // Is Favorites
            favoriteButton.markAs(isFavorites: auditorium.isFavorite)
            
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
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let url = logic.shareURL() else {
            return
        }
        share(url)
    }
    
    // MARK: - Favorites
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBAction func toggleFavorite(_ sender: Any) {
        logic.toggleFavorite()
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
            let vc = segue.destination as! NewAuditoriumTableViewController
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

// MARK: - EntityTableViewControllerDelegate

extension AuditoriumViewController: EntityTableViewControllerDelegate {
    
    func didBeginRefresh(in viewController: EntityTableViewController) {
        // Import records on "pull to refresh"
        // Don't show activity indicator in the center of the screen
        logic.importRecords(showActivity: false)
    }
}

// MARK: - EntityLogicControllerDelegate

extension AuditoriumViewController: EntityLogicControllerDelegate {
    
    func didChangeState(to newState: EntityViewController.State) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension AuditoriumViewController: ErrorAlertRepresentable {}
