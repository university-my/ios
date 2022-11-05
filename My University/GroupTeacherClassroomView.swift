//
//  GroupTeacherClassroomView.swift
//  My University
//
//  Created by Yura Voevodin on 27.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GroupTeacherClassroomView: View {
    var data: ModelData
    private(set) var university: University.CodingData
    
    var body: some View {
        switch data.type {
        case .group:
            GroupView(model: GroupViewModel(model: data, university: university))
        default:
            EmptyView()
        }
    }
}

struct GroupTeacherClassroomView_Previews: PreviewProvider {
    static var previews: some View {
        GroupTeacherClassroomView(data: ModelData.testGroup, university: University.CodingData.testData)
    }
}
