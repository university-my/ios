//
//  AboutUsTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 15.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class AboutUsTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            switch row {
            case 0:
                if let websiteURL = URL(string: "https://my-university.com.ua") {
                    UIApplication.shared.open(websiteURL)
                }
            case 1:
                if let facebookPageURL = URL(string: "https://www.facebook.com/myuniversityservice") {
                    UIApplication.shared.open(facebookPageURL)
                }
            case 2:
                if let twitterURL = URL(string: "https://twitter.com/myuniversity_su") {
                    UIApplication.shared.open(twitterURL)
                }
            case 3:
                if let instagramURL = URL(string: "https://www.instagram.com/university.my/") {
                    UIApplication.shared.open(instagramURL)
                }
            default:
                break
            }
            
        } else if section == 1, row == 0 {
            if let appURL = URL(string: "https://itunes.apple.com/ua/app/university-schedule/id1440425058") {
                UIApplication.shared.open(appURL)
            }
            
        } else if section == 2 {
            switch row {
            case 0:
                performSegue(withIdentifier: "showWebView", sender: (title: "Privacy Policy", url: "https://my-university.com.ua/privacy-policy"))
                
            case 1:
                performSegue(withIdentifier: "showWebView", sender: (title: "Terms of Service", url: "https://my-university.com.ua/terms-of-service"))
                
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showWebView":
            let vc = segue.destination as? WebViewController
            if let (title, url) = (sender as? (String, String)) {
                vc?.urlString = url
                vc?.title = title
            }
            
        default:
            break
        }
    }
}
