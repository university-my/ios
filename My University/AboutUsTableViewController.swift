//
//  AboutUsTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 15.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class AboutUsTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            switch row {
            case 0:
                performSegue(withIdentifier: "legalDocument", sender: LegalDocument.privacyPolicy)
                
            case 1:
                performSegue(withIdentifier: "legalDocument", sender: LegalDocument.termsOfService)
                
            default:
                break
            }
            
        } else if section == 1 {
            if let websiteURL = URL(string: "https://my-university.com.ua") {
                UIApplication.shared.open(websiteURL)
            }
            
        } else if section == 2 {
            if let patreonURL = URL(string: "https://www.patreon.com/my_university") {
                UIApplication.shared.open(patreonURL)
            }
            
        } else if section == 3 {
            // What's new in version 1.6.3
            var whatsNewView = WhatsNewOneSixThree()
            
            // Continue
            whatsNewView.continueAction = {
                self.dismiss(animated: true)
            }
            
            let hostingController = UIHostingController(rootView: whatsNewView)
            present(hostingController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else if section == 4 {
            switch row {
            case 0:
                if let facebookPageURL = URL(string: "https://www.facebook.com/myuniversityservice") {
                    UIApplication.shared.open(facebookPageURL)
                }
            case 1:
                if let instagramURL = URL(string: "https://www.instagram.com/university.my/") {
                    UIApplication.shared.open(instagramURL)
                }
            case 2:
                if let telegramURL = URL(string: "https://t.me/university_my") {
                    UIApplication.shared.open(telegramURL)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "legalDocument":
            let vc = segue.destination as? LegalDocumentViewController
            vc?.documentName = sender as? String
            
        default:
            break
        }
    }
    
    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
}
