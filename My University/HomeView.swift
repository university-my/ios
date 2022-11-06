//
//  HomeView.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @StateObject var model: HomeViewModel
    
    var body: some View {
        NavigationStack {
            if let university = model.university {
                if let data = model.data {
                    GroupTeacherClassroomView(model: GroupTeacherClassroomViewModel(data: data, university: university))
                } else {
                    VStack(spacing: 10) {
                        Text(university.fullName)
                        Button() {
                            model.beginSearch()
                        } label: {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .controlSize(.regular)
                        .buttonStyle(.borderedProminent)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                model.presentInformation()
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Button {
                        model.selectUniversity()
                    } label: {
                        Label("Select University", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(GradientButton())
                }.toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            model.presentInformation()
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
