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
    
    let model = HomeViewModel()
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = HomeView(model: self.model)
        super.init(coder: aDecoder, rootView: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
        
        if let university = University.current {
            model.update(with: university)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case .presentUniversitiesList:
            let controller = segue.destination as? UniversitiesListHostingController
            controller?.delegate = self
            
        case .presentInformation:
            let navigation = segue.destination as? UINavigationController
            let controller = navigation?.viewControllers.first as? InformationHostingController
            controller?.delegate = self
            
        default:
            break
        }
    }
}

// MARK: - HomeViewModelDelegate

extension HomeHostingController: HomeViewModelDelegate {
    func homeViewModelBeginSearchPressed() {
        performSegue(withIdentifier: .presentSearch, sender: nil)
    }
    
    func homeViewModelSelectUniversityPressed() {
        performSegue(withIdentifier: .presentUniversitiesList, sender: nil)
    }
}

// MARK: - UniversitiesListHostingControllerDelegate

extension HomeHostingController: UniversitiesListHostingControllerDelegate {
    func universitiesListHostingController(didSelectUniversity university: University.CodingData) {
        University.current = university
        model.update(with: university)
    }
}

// MARK: - InformationHostingControllerDelegate

extension HomeHostingController: InformationHostingControllerDelegate {
    func informationHostingControllerChangeUniversityPressed(in controller: InformationHostingController) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: .presentUniversitiesList, sender: nil)
        }
    }
}

// MARK: - SegueIdentifier

private extension HomeHostingController.SegueIdentifier {
    static let presentUniversitiesList = "presentUniversitiesList"
    static let presentInformation = "presentInformation"
    static let presentSearch = "presentSearch"
}
