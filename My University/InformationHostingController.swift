//
//  InformationHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class InformationHostingController: UIHostingController<InformationView> {
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = InformationView()
        super.init(coder: aDecoder, rootView: view)
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
}
