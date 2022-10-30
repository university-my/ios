//
//  GroupViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 30.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

@MainActor
final class GroupViewModel: ObservableObject {
    @Published private(set) var data: ModelData
    
    init(data: ModelData) {
        self.data = data
    }
    
    func fetchData() {
        
    }
}
