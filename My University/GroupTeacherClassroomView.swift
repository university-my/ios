//
//  GroupTeacherClassroomView.swift
//  My University
//
//  Created by Yura Voevodin on 27.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GroupTeacherClassroomView: View {
    @StateObject var model: GroupTeacherClassroomViewModel
    
    var body: some View {
        GroupTeacherClassroomContentView(data: model.data, university: model.university, date: model.date)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
//                        model.presentInformation()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                ToolbarItem(placement: .status) {
                    DatePicker(
                        "",
                        selection: $model.date,
                        in: Date.dateRange(for: model.date),
                        displayedComponents: [.date]
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(model.data.data.name)
    }
}

struct GroupTeacherClassroomContentView: View {
    
    var data: ModelData
    private(set) var university: University.CodingData
    private(set) var date: Date
    
    var body: some View {
        switch data.type {
        case .group:
            GroupView(model: GroupViewModel(model: data, date: date, university: university))
        default:
            EmptyView()
        }
    }
}

struct GroupTeacherClassroomView_Previews: PreviewProvider {
    static var previews: some View {
        GroupTeacherClassroomView(model: GroupTeacherClassroomViewModel(data: .testGroup, university: .testData))
    }
}
