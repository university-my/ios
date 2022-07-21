//
//  SearchHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class SearchHostingController: UIHostingController<SearchView> {
    
    let model = SearchViewModel()
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = SearchView(model: self.model)
        super.init(coder: aDecoder, rootView: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.update(with: University.current)
    }
}
