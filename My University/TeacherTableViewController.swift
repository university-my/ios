//
//  TeacherTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 12.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

final class TeacherTableViewController: EntityTableViewController<TeacherModel, TeacherEntity> {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        dataController = Teacher.TableDataController()
        
        super.viewDidLoad()
    }
    
    // MARK: - Title
    
    @IBOutlet weak var tableTitleLabel: UILabel!
    
    override var titleText: String? {
        didSet {
            tableTitleLabel.text = titleText
        }
    }
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        delegate?.didBeginRefresh()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "recordDetails":
            if let navigation = segue.destination as? UINavigationController {
                if let destination = navigation.viewControllers.first as? RecordDetailedTableViewController {
                    destination.recordID = (sender as? Record)?.id
                    destination.groupID = nil
                    destination.teacherID = entityID
                    destination.classroomID = nil
                }
            }
            
        default:
            break
        }
    }
}
