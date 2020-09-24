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
    
    @IBOutlet weak var privacyPolicyCell: UITableViewCell!
    @IBOutlet weak var termsOfServiceCell: UITableViewCell!
    @IBOutlet weak var websiteCell: UITableViewCell!
    @IBOutlet weak var whatsNewCell: UITableViewCell!
    @IBOutlet weak var facebookCell: UITableViewCell!
    @IBOutlet weak var instagramCell: UITableViewCell!
    @IBOutlet weak var telegramCell: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performAction(at: indexPath)
    }
    
    func performAction(at indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        switch selectedCell {
        
        case privacyPolicyCell:
            performSegue(withIdentifier: "legalDocument", sender: LegalDocument.privacyPolicy)
            
        case termsOfServiceCell:
            performSegue(withIdentifier: "legalDocument", sender: LegalDocument.termsOfService)
            
        case websiteCell:
            if let websiteURL = URL(string: "https://my-university.com.ua") {
                UIApplication.shared.open(websiteURL)
            }
            
        case whatsNewCell:
            // What's new
            var whatsNewView = WhatsNewView()
            
            // Continue
            whatsNewView.continueAction = {
                self.dismiss(animated: true)
            }
            
            let hostingController = UIHostingController(rootView: whatsNewView)
            present(hostingController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        case facebookCell:
            if let facebookPageURL = URL(string: "https://www.facebook.com/myuniversityservice") {
                UIApplication.shared.open(facebookPageURL)
            }
            
        case instagramCell:
            if let instagramURL = URL(string: "https://www.instagram.com/university.my/") {
                UIApplication.shared.open(instagramURL)
            }
            
        case telegramCell:
            if let telegramURL = URL(string: "https://t.me/university_my") {
                UIApplication.shared.open(telegramURL)
            }
            
        default:
            break
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
