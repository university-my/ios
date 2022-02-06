//
//  ActivityAlertViewController.swift
//  My University
//
//  Created by Yura Voevodin on 17.12.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import UIKit

class ActivityAlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = titleText
        messageLabel.text = messageText
    }
    
    // MARK: - Labels
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var titleText: String?
    private var messageText: String?
    
    func update(title: String?, message: String?) {
        titleText = title
        messageText = message
    }
}
