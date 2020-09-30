//
//  TeacherViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class TeacherViewController: EntityViewController {
    
    // MARK: - Properties
    
    private let logic: TeacherLogicController
    
    /// `UITableView`
    var tableViewController: NewTeacherTableViewController!
    
    /// Show an activity indicator over current `UIViewController`
    let activityController = ActivityController()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = TeacherLogicController(activity: activityController)
        
        super.init(coder: coder)

        logic.delegate = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save last opened entity to UserDefaults
        let entity = Entity(kind: .teacher, id: entityID)
        Entity.Manager.shared.update(with: entity)
        
        // Data
        logic.fetchData(for: entityID)
        
        configureMenu()
    }
    
    // MARK: - Teacher
    
    var teacher: TeacherEntity? {
        return logic.teacher
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
            guard let teacher = structure as? Teacher else {
                preconditionFailure()
            }
            
            // Title
            tableViewController.tableTitleLabel.text = teacher.name
            
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
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    private var menuPresenter: EntityMenuPresenter!
    
    func configureMenu() {
        let config = EntityMenuPresenter.Config(item: menuBarButtonItem) {
            if let url = self.logic.shareURL() {
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
    
    var isFavorite: Bool {
        teacher?.isFavorite ?? false
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
            let vc = segue.destination as! NewTeacherTableViewController
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

extension TeacherViewController: EntityTableViewControllerDelegate {
    
    func didBeginRefresh(in viewController: EntityTableViewController) {
        // Import records on "pull to refresh"
        // Don't show activity indicator in the center of the screen
        logic.importRecords(showActivity: false)
    }
    
    func didDismissDetails(in viewController: EntityTableViewController) {
        logic.makeReviewRequestIfNeeded()
    }
}

// MARK: - EntityLogicControllerDelegate

extension TeacherViewController: EntityLogicControllerDelegate {
    
    func didChangeState(to newState: EntityViewController.State) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension TeacherViewController: ErrorAlertRepresentable {}
