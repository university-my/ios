//
//  PreferencesTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 24.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class PreferencesTableViewController: UITableViewController {

    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Report a problem
    
    @IBOutlet weak var reportProblemCell: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell == reportProblemCell {
            if let websiteURL = URL(string: "https://my-university.com.ua/contacts") {
                UIApplication.shared.open(websiteURL)
            }
        }
    }
}
