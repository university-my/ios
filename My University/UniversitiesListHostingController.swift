//
//  UniversitiesListHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class UniversitiesListHostingController: UIHostingController<UniversitiesListView> {
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let model = UniversitiesListViewModel(
            dataProvider: UniversitiesListDataProvider(
                networkClient: UniversitiesListNetworkClient()
            )
        )
        super.init(coder: aDecoder, rootView: UniversitiesListView(model: model))
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
}
