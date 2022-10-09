//
//  SearchHostingController.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

protocol SearchHostingControllerDelegate: AnyObject {
    func searchHostingController(didSelectObject object: ObjectType)
}

final class SearchHostingController: UIHostingController<SearchView> {
    
    weak var delegate: SearchHostingControllerDelegate?
    let model = SearchViewModel()
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let view = SearchView(model: self.model)
        super.init(coder: aDecoder, rootView: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.update(with: University.current)
    }
}

extension SearchHostingController: SearchViewModelDelegate {
    func searchViewModel(didSelectObject object: ObjectType) {
        delegate?.searchHostingController(didSelectObject: object)
        dismiss(animated: true)
    }
}
