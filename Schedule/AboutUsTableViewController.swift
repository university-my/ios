//
//  AboutUsTableViewController.swift
//  Schedule
//
//  Created by Yura Voevodin on 15.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import UIKit

class AboutUsTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
}
