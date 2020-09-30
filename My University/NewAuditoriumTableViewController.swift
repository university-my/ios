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
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
            
        case .recordDetails:
            if let navigation = segue.destination as? UINavigationController {
                if let destination = navigation.viewControllers.first as? RecordDetailedTableViewController {
                    destination.recordID = (sender as? Record)?.id
                    destination.groupID = nil
                    destination.teacherID = nil
                    destination.auditoriumID = entityID
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - SegueIdentifier

private extension NewAuditoriumTableViewController.SegueIdentifier {
    static let recordDetails = "recordDetails"
}
