//
//  InformationTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 9/13/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class InformationTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        tableView.delegate = self
    }

  // MARK: - Done

  @IBAction func done(_ sender: Any) {
    dismiss(animated: true)
  }

  // MARK: - Feedback

  @IBOutlet weak var feedbackCell: UITableViewCell!

  // MARK: - Web version

  var webPage: WebPage?
  @IBOutlet weak var webVersionCell: UITableViewCell!

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }

    if cell == webVersionCell {
      performSegue(withIdentifier: "showWebView", sender: webPage)

    } else if cell == feedbackCell {
      if let telegramURL = URL(string: "https://t.me/voevodin_yura") {
          UIApplication.shared.open(telegramURL)
      }
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {

    case "showWebView":
      let vc = segue.destination as? WebViewController
      vc?.webPage = sender as? WebPage

    default:
      break
    }
  }
}
