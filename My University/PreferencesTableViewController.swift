//
//  PreferencesTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 24.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

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
    
    // MARK: - Table view delegate
    
    @IBOutlet weak var reportProblemCell: UITableViewCell!
    @IBOutlet weak var patreonCell: UITableViewCell!
    @IBOutlet weak var newFeatures: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell == reportProblemCell {
            UIApplication.shared.open(BaseEndpoint.contacts.url)
        } else if cell == patreonCell {
            if let patreonURL = URL(string: "https://www.patreon.com/my_university") {
                UIApplication.shared.open(patreonURL)
            }
        } else if cell == newFeatures {
            // What's new in version 1.6.3
            var whatsNewView = WhatsNewOneSixThree()

            // Continue
            whatsNewView.continueAction = {
                self.dismiss(animated: true)
            }

            let hostingController = UIHostingController(rootView: whatsNewView)
            present(hostingController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
