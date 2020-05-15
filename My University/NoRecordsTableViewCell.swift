//
//  NoRecordsTableViewCell.swift
//  My University
//
//  Created by Yura Voevodin on 26.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit
import MyLibrary

class NoRecordsTableViewCell: UITableViewCell, NibLoadableView, ReusableView {
    
    // MARK: - Images
    
    let images: [UIImage?] = [
        UIImage(named: "1 Working remotely"),
        UIImage(named: "2 Effective UI"),
        UIImage(named: "4 Multitasking"),
        UIImage(named: "6 Working at desk"),
        UIImage(named: "7 Social Media"),
        UIImage(named: "8 Work and life balance"),
        UIImage(named: "13 Walking the dog")
    ]
    
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    func updateWithRandomImage() {
        let images = self.images.compactMap { $0 }
        placeholderImageView.image = images.randomElement()
    }
}
