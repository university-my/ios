//
//  PreferencesTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 24.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class PreferencesTableViewController: UITableViewController {

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {

        case "privacyPolicy":
            let vc = segue.destination as? LegalDocumentViewController
            vc?.documentName = LegalDocument.privacyPolicy

        case "termsOfService":
            let vc = segue.destination as? LegalDocumentViewController
            vc?.documentName = LegalDocument.termsOfService

        default:
            break
        }
    }

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
