//
//  UniversityViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class UniversityViewController: UITableViewController {

    // MARK: - Properties

    weak var university: UniversityEntity?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = university?.shortName
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
}
