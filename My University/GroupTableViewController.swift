//
//  GroupTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 19.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class GroupTableViewController: EntityTableViewController<ModelKinds.GroupModel, GroupEntity> {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        dataController = Group.TableDataController()
        
        super.viewDidLoad()
    }
    
    // MARK: - Title
    
    @IBOutlet weak var tableTitleLabel: UILabel!
    
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
                    destination.groupID = entityID
                    destination.teacherID = nil
                    destination.classroomID = nil
                    destination.delegate = self
                }
            }
            
        default:
            break
        }
    }
}
