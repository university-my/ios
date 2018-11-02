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
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let facebookURL = URL(string: "fb://profile/120391101921477"), UIApplication.shared.canOpenURL(facebookURL) {
                    UIApplication.shared.open(facebookURL)
                } else if let facebookPageURL = URL(string: "https://www.facebook.com/botschedule") {
                    UIApplication.shared.open(facebookPageURL)
                }
            case 1:
                if let messengerBotURL = URL(string: "https://m.me/botschedule") {
                    UIApplication.shared.open(messengerBotURL)
                }
            case 2:
                if let telegramBotURL = URL(string: "https://telegram.me/sumdu_bot") {
                    UIApplication.shared.open(telegramBotURL)
                }
            default:
                break
            }
            
        } else if indexPath.section == 1, indexPath.row == 0 {
            if let appURL = URL(string: "https://itunes.apple.com/ua/app/university-schedule/id1440425058") {
                UIApplication.shared.open(appURL)
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                if let privacyPolicyURL = URL(string: "https://voevodin-yura.com/privacy-policy") {
                    UIApplication.shared.open(privacyPolicyURL)
                }
            case 1:
                if let termsOfServiceURL = URL(string: "https://voevodin-yura.com/terms-of-service") {
                    UIApplication.shared.open(termsOfServiceURL)
                }
            default:
                break
            }
        }
        
    }
}
