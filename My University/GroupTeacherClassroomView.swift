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
        let model = ModelData(
            data: ModelCodingData(id: 1, name: "Test", slug: "test", uuid: UUID()),
            type: .group
        )
        return GroupTeacherClassroomView(data: model, university: University.CodingData.first)
    }
}

private extension University.CodingData {
    static var first: Self {
        University.CodingData(
            id: 1,
            fullName: "First University Full Very Long Name Name",
            shortName: "First Short Name",
            logoLight: "1_light.png",
            logoDark: "1_dark.png"
        )
    }
}
