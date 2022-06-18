//
//  HomeHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

class HomeHostingController: UIHostingController<HomeView> {
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = HomeView()
        super.init(coder: aDecoder, rootView: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if University.selectedUniversityID == nil {
            performSegue(withIdentifier: .presentUniversitiesList, sender: nil)
        } else {
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - SegueIdentifier

private extension HomeHostingController.SegueIdentifier {
    static let presentUniversitiesList = "presentUniversitiesList"
}
