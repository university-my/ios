//
//  TeacherViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

final class TeacherViewController: EntityViewController<TeacherModel, TeacherEntity> {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logic = Teacher.LogicController(activity: activityController)
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
            
        case "records":
            let controller = segue.destination as! TeacherTableViewController
            tableViewController = controller
            tableViewController.delegate = self
            
        case "presentDatePicker":
            let navigationVC = segue.destination as? UINavigationController
            let controller = navigationVC?.viewControllers.first as? DatePickerViewController
            controller?.pairDate = pairDate
            controller?.didSelectDate = { selectedDate in
                self.logic.changePairDate(to: selectedDate)
            }
            
        default:
            break
        }
    }
}
