//
//  RecordTableViewCell.swift
//  My University
//
//  Created by Yura Voevodin on 22.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell, ReusableView {

    // MARK: - Update
    
    func update(with record: RecordEntity) {
        let title = record.title
        let detail = record.detail
        
        if title.isEmpty && detail.isEmpty {
            textLabel?.text = record.reason
        } else {
            textLabel?.text = title
            detailTextLabel?.text = detail
        }
    }
}
