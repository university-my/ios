//
//  ClassroomViewController.swift
//  My University
//
//  Created by Yura Voevodin on 01.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

final class ClassroomViewController: EntityViewController<ModelKinds.ClassroomModel, ClassroomEntity> {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logic = Classroom.LogicController(activity: activityController)
        logic.delegate = self
        
        // Data
        logic.fetchData(for: entityID)
        
        configureMenu()
    }
    
    // MARK: - Menu
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    override var menuItem: UIBarButtonItem? {
        menuBarButtonItem
    }
    
    // MARK: - Date
    
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
            
        case .records:
            let vc = segue.destination as! ClassroomTableViewController
            tableViewController = vc
            tableViewController.delegate = self
            
        case .presentDatePicker:
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

// MARK: - SegueIdentifier

private extension ClassroomViewController.SegueIdentifier {
    static let presentDatePicker = "presentDatePicker"
    static let records = "records"
    static let setUniversity = "setUniversity"
}
