//
//  GroupTeacherClassroomViewModel.swift
//  My University
//
//  Created by Yura Voevodin on 06.11.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

@MainActor
class GroupTeacherClassroomViewModel: ObservableObject {
    @Published var date: Date
    private(set) var data: ModelData
    private(set) var university: University.CodingData
    
    init(data: ModelData, university: University.CodingData) {
        self.date = Date()
        self.data = data
        self.university = university
    }
}
