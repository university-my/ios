//
//  GroupTeacherClassroomView.swift
//  My University
//
//  Created by Yura Voevodin on 27.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GroupTeacherClassroomView: View {
    var object: ObjectType
    
    var body: some View {
        switch object.scope {
        case .groups:
            GroupView()
        default:
            EmptyView()
        }
    }
}

struct GroupTeacherClassroomView_Previews: PreviewProvider {
    static var previews: some View {
        GroupTeacherClassroomView(object: ObjectType(id: 1, scope: .groups))
    }
}
