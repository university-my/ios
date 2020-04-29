//
//  GroupViewController.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    
    // MARK: - Properties
    
    private let logic: GroupLogicController
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        logic = GroupLogicController()
        super.init(coder: coder)
        
        logic.delegate = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        logic.fetchData(for: groupID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show toolbar
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - State
        
        enum State {
            case loading
            case presenting(Group)
            case failed(Error)
        }
        
        func render(_ state: State) {
            switch state {
                
            case .loading:
                
                // TODO: Add "showActivity: Bool" property
                // TODO: Import (update) new records without activity indication, if records are present
                
                // Show a loading spinner
                showActivity()
                
            case .presenting(let group):
                // Bind the user model to the view controller's views
                
                // Title
                tableViewController.tableTitleLabel.text = group.name
                
                // Is Favorites
                favoriteButton.markAs(isFavorites: group.isFavorite)
                
                // Controller title
                title = DateFormatter.date.string(from: pairDate)

                tableViewController.update(with: logic.sections)
                
                hideActivity()
                
            case .failed(let error):
                hideActivity()
                
                // Show an error view
                present(error) {
                    // Try again
                    self.logic.importRecordsIfNeeded()
                }
                tableViewController.refreshControl?.endRefreshing()
            }
        }

    // MARK: - Group
    
    var groupID: Int64!
    
    var group: GroupEntity? {
        return logic.group
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        guard let url = logic.shareURL() else { return }
        let sharedItems = [url]
        let vc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(vc, animated: true)
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
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    @IBAction func previousDate(_ sender: Any) {
        logic.previousDate()
    }
    
    @IBAction func nextDate(_ sender: Any) {
        logic.nextDate()
    }
    
    // MARK: - Table
    
    var tableViewController: GroupTableViewController!
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "records":
            let vc = segue.destination as! GroupTableViewController
            tableViewController = vc
            
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
    
    // MARK: - Activity
    
    /// Reference to the view controller with `UIActivityIndicatorView`
    /// Can be added as child to any  subclass of `ViewController`
    private var activityViewController: ActivityViewController?
    
    func showActivity(with text: String? = nil) {
        guard let child = storyboard?.instantiateViewController(identifier: "ActivityViewController") as? ActivityViewController else {
            return
        }

        // Add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        activityViewController = child
    }

    func hideActivity() {
        if let child = activityViewController {
            // Remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

// MARK: - GroupLogicControllerDelegate

extension GroupViewController: GroupLogicControllerDelegate {
    
    func didChangeState(to newState: State) {
        render(newState)
    }
}

// MARK: - ErrorAlertRepresentable

extension GroupViewController: ErrorAlertRepresentable {}
