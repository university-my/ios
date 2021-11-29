//
//  TeacherViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

final class TeacherViewController: EntityViewController<ModelKinds.TeacherModel, TeacherEntity> {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logic = Teacher.LogicController(activity: activityController)
        logic.delegate = self
        
        // Save last opened entity to UserDefaults
        let entity = Entity(kind: .teacher, id: entityID)
        Entity.Manager.shared.update(with: entity)
        
        // Data
        logic.fetchData(for: entityID)
        
        configureMenu()
    }
    
    // MARK: - Teacher
    
    var teacher: TeacherEntity? {
        logic.entity
    }
    
    // MARK: - Menu
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    override var menuItem: UIBarButtonItem? {
        menuBarButtonItem
    }
    
    override var isFavorite: Bool {
        teacher?.isFavorite ?? false
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
