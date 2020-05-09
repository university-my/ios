//
//  NewAuditoriumTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit

class NewAuditoriumTableViewController: EntityTableViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        dataController = AuditoriumTableDataController()
        
        super.viewDidLoad()
    }
    
    // MARK: - Title
    
    @IBOutlet weak var tableTitleLabel: UILabel!
    
    // MARK: - Pull to refresh
    
    @IBAction func refresh(_ sender: Any) {
        delegate?.didBeginRefresh(in: self)
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
                    destination.auditoriumID = nil
                }
            }
            
        default:
            break
        }
    }
}
